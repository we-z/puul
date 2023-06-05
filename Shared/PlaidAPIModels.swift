//
//  PlaidAPIModels.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 5/3/23.
//

import Foundation
import SwiftUI

class PlaidModel: ObservableObject {
    let bankAccountsKey: String = "bankaccounts"
    let brokerAccountsKey: String = "brokeraccounts"
    let networthKey: String = "networth"
    var bankString: String = ""
    var brokerString: String = ""
    var isUpdating = false
    let plaidEnvironment = "https://sandbox.plaid.com/"
    @Published var linkToken = ""
    @Published var totalNetWorth: Double = 0
    var newBankAccounts: [BankAccount] = []
    var newBrokerAccounts: [BrokerAccount] = []
    @Published var bankAccounts: [BankAccount] = [] {
        didSet{
            saveBankAccounts()
            updateBankString()
        }
    }
    @Published var brokerAccounts: [BrokerAccount] = [] {
        didSet{
            saveBrokerAccounts()
            updateBrokerString()
        }
    }
    
    init() {
        getBankAccounts()
        getBrokerAccounts()
        calculateNetworth()
    }
    
    // call when refreshing
    func updateAccounts(){
        isUpdating = true
        bankAccounts.forEach { account in
            self.getBankAccount(accessToken: account.access_token)
        }
        if bankAccounts.count == newBankAccounts.count{
            bankAccounts = newBankAccounts
            newBankAccounts = []
        }
        
        brokerAccounts.forEach { account in
            self.getBrokerAccount(accessToken: account.access_token)
        }
        if brokerAccounts.count == newBrokerAccounts.count {
            brokerAccounts = newBrokerAccounts
        }
        
    }

    func updateBankString(){
        bankString = ""
        
        bankAccounts.forEach { account in
            bankString += "I have " + account.balance.withCommas() + " in my " + account.institution_name + " bank account\n\n"
            bankString += "I spent:\n"
            account.transactions.forEach{ transaction in
                if transaction.amount > 0 {
                    bankString += "$" + String(transaction.amount) + " at " + transaction.merchant + " on " + transaction.dateTime + "\n"
                }
            }
            bankString += " \n"
            bankString += "I made:\n"
            account.transactions.forEach{ transaction in
                if transaction.amount < 0 {
                    bankString += "$" + String(abs(transaction.amount)) + " from " + transaction.merchant + " on " + transaction.dateTime + "\n"
                }
            }
            bankString += " \n"
            
            
        }
        //print(bankString)
    }
    
    func updateBrokerString(){
        brokerString = ""
        
        brokerAccounts.forEach { account in
            brokerString += "I have " + account.balance.withCommas() + " in my " + account.institution_name + " investing account:\n"
            //brokerString += "in my " + account.institution_name + " investing account I have:\n"
            account.holdings.forEach{ security in
                brokerString += "$" + String(security.value) + " of " + security.name + "\n"
            }
            brokerString += " \n"
        }
        //print(brokerString)
    }
    
    func calculateNetworth() {
        totalNetWorth = 0
        bankAccounts.forEach { account in
            self.totalNetWorth += account.balance
        }
        brokerAccounts.forEach { account in
            self.totalNetWorth += account.balance
        }
    }


    func deleteBankAccount(indexSet: IndexSet) {
        bankAccounts.remove(atOffsets: indexSet)
    }
    
    func deleteBrokerAccount(indexSet: IndexSet) {
        brokerAccounts.remove(atOffsets: indexSet)
    }
    
    func getBankAccounts(){
        guard
            let accountData = UserDefaults.standard.data(forKey: bankAccountsKey),
            let savedAccounts = try? JSONDecoder().decode([BankAccount].self, from: accountData)
        else {return}
        
        self.bankAccounts = savedAccounts
    }
    
    func getBrokerAccounts(){
        guard
            let accountData = UserDefaults.standard.data(forKey: brokerAccountsKey),
            let savedAccounts = try? JSONDecoder().decode([BrokerAccount].self, from: accountData)
        else {return}
        
        self.brokerAccounts = savedAccounts
    }
    
    func clearBankAccounts(){
        self.bankAccounts = []
        self.totalNetWorth = 0
    }
    
    func addBankAccount(institutionId: String, accessToken: String, institutionName: String, totalBalance: Double, transactions: [BankTransaction]){
        let newAccount = BankAccount(institution_id: institutionId, access_token: accessToken, institution_name: institutionName, balance: totalBalance, transactions: transactions)
        if (isUpdating) {
            DispatchQueue.main.async {
                self.newBankAccounts.append(newAccount)
            }
            print("Bank Refresh worked")
        } else {
            DispatchQueue.main.async {
                self.bankAccounts.append(newAccount)
            }
            print("New Bank account added")
        }
        
    }
    
    func addBrokerAccount(institutionId: String, accessToken: String, institutionName: String, totalBalance: Double, holdings: [Security]){
        let newAccount = BrokerAccount(institution_id: institutionId, access_token: accessToken, institution_name: institutionName, balance: totalBalance, holdings: holdings)
        if (isUpdating) {
            DispatchQueue.main.async {
                self.newBrokerAccounts.append(newAccount)
            }
            print("Broker Refresh worked")
        } else {
            DispatchQueue.main.async {
                self.brokerAccounts.append(newAccount)
            }
            print("New Broker account added")
        }
        
    }
    
    func saveBankAccounts() {
        if let bankData = try? JSONEncoder().encode(bankAccounts){
            UserDefaults.standard.set(bankData, forKey: bankAccountsKey)
        }
        self.calculateNetworth()
    }
    
    func saveBrokerAccounts() {
        if let brokerData = try? JSONEncoder().encode(brokerAccounts){
            UserDefaults.standard.set(brokerData, forKey: brokerAccountsKey)
        }
        self.calculateNetworth()
    }
    
    
    func createBrokerLinkToken() {
        guard let url = URL(string: plaidEnvironment + "link/token/create") else {
            print("Invalid URL")
            return
        }
        
        let parameters = [
            "client_id": "63d411aa2bcbe80013f42ad7",
            "secret": "4c8e7956ddd4dcb6d91177841fc850",
            "user": [
                "client_user_id": "unique-per-user"
            ],
            "client_name": "Puul",
            "products": ["investments"],
            "country_codes": ["US"],
            "language": "en",
            "redirect_uri": "https://cdn-testing.plaid.com/link/v2/stable/sandbox-oauth-a2a-redirect.html",
            "account_filters": [
                "investment": [
                    "account_subtypes": ["ira", "401k"]
                ]
            ]
        ] as [String : Any]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            print("Invalid body parameters")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error fetching linkToken: \(error.localizedDescription)")
            } else if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let linkToken = json?["link_token"] as? String {
                        DispatchQueue.main.async {
                            self.linkToken = linkToken
                        }
                        print("Link token: \(self.linkToken)")
                    }
                } catch {
                    print("Error decoding response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func createBankLinkToken() {
        guard let url = URL(string: plaidEnvironment + "link/token/create") else {
            print("Invalid URL")
            return
        }
        
        let parameters = [
            "client_id": "63d411aa2bcbe80013f42ad7",
            "secret": "4c8e7956ddd4dcb6d91177841fc850",
            "user": [
                "client_user_id": "unique-per-user"
            ],
            "client_name": "Puul",
            "products": ["auth", "transactions"],
            "country_codes": ["US"],
            "language": "en",
            "redirect_uri": "https://cdn-testing.plaid.com/link/v2/stable/sandbox-oauth-a2a-redirect.html",
            "account_filters": [
                "depository": [
                    "account_subtypes": ["checking"]
                ]
            ]
        ] as [String : Any]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            print("Invalid body parameters")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error fetching linkToken: \(error.localizedDescription)")
            } else if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let linkToken = json?["link_token"] as? String {
                        DispatchQueue.main.async {
                            self.linkToken = linkToken
                            print("Link token: \(self.linkToken)")
                        }
                    }
                } catch {
                    print("Error decoding response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func exchangePublicToken(publicToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        isUpdating = false
        let apiUrl = plaidEnvironment + "item/public_token/exchange"
        guard let url = URL(string: apiUrl) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let requestBody = ["client_id": "63d411aa2bcbe80013f42ad7", "secret": "4c8e7956ddd4dcb6d91177841fc850", "public_token": publicToken]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "No data returned", code: 0, userInfo: nil)))
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let accessToken = json?["access_token"] as? String {
                        completion(.success(accessToken))
                    } else {
                        completion(.failure(NSError(domain: "No access_token found in response", code: 0, userInfo: nil)))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
            
        } catch {
            completion(.failure(error))
        }
    }
    
    func getBankAccount(accessToken: String) {
        var totalBalance = 0.0
        let url = URL(string: plaidEnvironment + "accounts/get")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody: [String: Any] = [
            "client_id": "63d411aa2bcbe80013f42ad7",
            "secret": "4c8e7956ddd4dcb6d91177841fc850",
            "access_token": accessToken
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]

                let item = json["item"] as! [String: Any]
                let institutionId = item["institution_id"] as! String

                let accountsArray = json["accounts"] as! [[String: Any]]

                for account in accountsArray {
                    let balance = account["balances"] as! [String: Any]
                    totalBalance += balance["current"] as! Double
                }
                
                self.getBankName(institutionId: institutionId, accessToken: accessToken, totalBalance: totalBalance)

                print("Bank account balance fetched: \(totalBalance) \(institutionId)")
                
            } catch let error {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func getBrokerAccount(accessToken: String) {
        var totalBalance = 0.0
        let url = URL(string: plaidEnvironment + "accounts/get")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody: [String: Any] = [
            "client_id": "63d411aa2bcbe80013f42ad7",
            "secret": "4c8e7956ddd4dcb6d91177841fc850",
            "access_token": accessToken
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]

                let item = json["item"] as! [String: Any]
                let institutionId = item["institution_id"] as! String
                //let institutionName: () = getInstitutionName(institutionId: institutionId)
                

                let accountsArray = json["accounts"] as! [[String: Any]]

                for account in accountsArray {
                    let balance = account["balances"] as! [String: Any]
                    totalBalance += balance["current"] as! Double
                }
                
                self.getBrokerName(institutionId: institutionId, accessToken: accessToken, totalBalance: totalBalance)

                print("Broker account balance fetched: \(totalBalance) \(institutionId)")
                
            } catch let error {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func getBrokerName(institutionId: String, accessToken: String, totalBalance: Double) {
        let url = URL(string: plaidEnvironment + "institutions/get_by_id")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody: [String: Any] = [
            "institution_id": institutionId,
            "client_id": "63d411aa2bcbe80013f42ad7",
            "secret": "4c8e7956ddd4dcb6d91177841fc850",
            "country_codes": ["US"] // Replace with the appropriate country code(s) for the institution
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let institution = json["institution"] as! [String: Any]
                let institutionName = institution["name"] as! String
                print("Broker: " + institutionName) // Do something with the institution name, e.g. return it or store it in a variable
                self.getBrokerholdings(institutionId: institutionId, accessToken: accessToken, totalBalance: totalBalance, institutionName: institutionName)
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }
    
    func getBankName(institutionId: String, accessToken: String, totalBalance: Double) {
        let url = URL(string: plaidEnvironment + "institutions/get_by_id")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody: [String: Any] = [
            "institution_id": institutionId,
            "client_id": "63d411aa2bcbe80013f42ad7",
            "secret": "4c8e7956ddd4dcb6d91177841fc850",
            "country_codes": ["US"] // Replace with the appropriate country code(s) for the institution
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let institution = json["institution"] as! [String: Any]
                let institutionName = institution["name"] as! String
                print("Bank name: " + institutionName) // Do something with the institution name, e.g. return it or store it in a variable
                
                self.getBankTransactions(institutionId: institutionId, accessToken: accessToken, totalBalance: totalBalance, institutionName: institutionName)

            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }

    func getBankTransactions(institutionId: String, accessToken: String, totalBalance: Double, institutionName: String) {
        let url = URL(string: plaidEnvironment + "transactions/get")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: endDate)!
        
        let requestData: [String: Any] = [
            "client_id": "63d411aa2bcbe80013f42ad7",
            "secret": "4c8e7956ddd4dcb6d91177841fc850",
            "access_token": accessToken,
            "start_date": formatDate(startDate),
            "end_date": formatDate(endDate),
            "options": [
                "count": 11,
                "offset": 0
            ]
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: requestData)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let transactionsData = json["transactions"] as! [[String: Any]]
                
                var transactions: [BankTransaction] = []
                
                for transactionData in transactionsData {
                    if let amount = transactionData["amount"] as? Double,
                       let dateTime = transactionData["date"] as? String,
                       let name = transactionData["merchant_name"] as? String {
                        let transaction = BankTransaction(amount: amount, merchant: name, dateTime: dateTime)
                        transactions.append(transaction)
                    }
                }
                self.addBankAccount(institutionId: institutionId, accessToken: accessToken, institutionName: institutionName, totalBalance: totalBalance, transactions: transactions)
                
            } catch {
                print("Error getting trasactions: \(error)")
            }
        }
        task.resume()
    }
    
    func getBrokerholdings(institutionId: String, accessToken: String, totalBalance: Double, institutionName: String) {
        let url = URL(string: plaidEnvironment + "investments/holdings/get")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let requestData: [String: Any] = [
            "client_id": "63d411aa2bcbe80013f42ad7",
            "secret": "4c8e7956ddd4dcb6d91177841fc850",
            "access_token": accessToken
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: requestData)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let securitiesData = json["securities"] as! [[String: Any]]
                                
                var securities: [Security] = []
                
                for position in securitiesData {
                    if let value = position["close_price"] as? Double,
                       let ticker = position["ticker_symbol"] as? String,
                       let name = position["name"] as? String {
                        let security = Security(ticker: ticker, name: name, value: value)
                        securities.append(security)
                    }
                }
                self.addBrokerAccount(institutionId: institutionId, accessToken: accessToken, institutionName: institutionName, totalBalance: totalBalance, holdings: securities)
                
            } catch {
                print("Error getting holdings: \(error)")
            }
            
        }
        task.resume()
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
}

extension Double {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}

struct BankAccount: Identifiable, Encodable, Decodable {
    var id = UUID()
    var institution_id: String
    var access_token: String
    var institution_name: String
    var balance: Double
    var transactions: [BankTransaction]
}

struct BankTransaction: Identifiable, Encodable, Decodable {
    var id = UUID()
    var amount: Double
    var merchant: String
    var dateTime: String
}

struct BrokerAccount: Identifiable, Encodable, Decodable {
    var id = UUID()
    var institution_id: String
    var access_token: String
    var institution_name: String
    var balance: Double
    var holdings: [Security]
}

struct Security: Identifiable, Encodable, Decodable {
    var id = UUID()
    var ticker: String
    var name: String
    var value: Double
}
