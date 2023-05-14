//
//  PlaidAPI.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 5/2/23.
//

import Foundation
import LinkKit
import SwiftUI

public struct PlaidLinkFlow: View {
    @Binding var showLink: Bool
    @Binding var isBank: Bool
    @State var linkToken = ""
    @EnvironmentObject var pm: PlaidModel
    
    public var body: some View {
        if linkToken.isEmpty{
            ProgressView()
                .onAppear{
                    if isBank == true {
                        createBankLinkToken()
                    } else {
                        createBrokerLinkToken()
                    }
                }
        } else {
            let linkController = LinkController(
                configuration: .linkToken(createLinkTokenConfiguration())
            ) { createError in
                print("Link Creation Error: \(createError)")
                self.showLink = false
            }
            
            linkController
                .onOpenURL { url in
                    linkController.linkHandler?.continue(from: url)
                }
        }
    }
    
    public func createLinkTokenConfiguration() -> LinkTokenConfiguration {
        
        var configuration = LinkTokenConfiguration(
            token: linkToken,
            onSuccess: { success in
                print("public-token: \(success.publicToken) metadata: \(success.metadata)")
                showLink = false
                exchangePublicToken(publicToken: success.publicToken) { result in
                    switch result {
                    case .success(let accessToken):
                        print("access_token: \(accessToken)")
                        if isBank == true {
                            getBankAccount(accessToken: accessToken)
                        } else {
                            getBrokerAccount(accessToken: accessToken)
                        }
                    case .failure(let error):
                        print("Error exchanging public token: \(error)")
                    }
                }
            }
        )

        configuration.onEvent = { event in
            print("Link Event: \(event)")
        }

        configuration.onExit = { exit in
            if let error = exit.error {
                print("exit with \(error)\n\(exit.metadata)")
            } else {
                print("exit with \(exit.metadata)")
            }
            linkToken = ""
            showLink = false
            pm.getBankAccounts()
        }
        

        return configuration
    }
    
    func createBrokerLinkToken() {
        guard let url = URL(string: "https://sandbox.plaid.com/link/token/create") else {
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
                        self.linkToken = linkToken
                        print("Link token: \(self.linkToken)")
                    }
                } catch {
                    print("Error decoding response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func createBankLinkToken() {
        guard let url = URL(string: "https://sandbox.plaid.com/link/token/create") else {
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
                        self.linkToken = linkToken
                        print("Link token: \(self.linkToken)")
                    }
                } catch {
                    print("Error decoding response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func exchangePublicToken(publicToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        let apiUrl = "https://sandbox.plaid.com/item/public_token/exchange"
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
        let url = URL(string: "https://sandbox.plaid.com/accounts/get")!
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
                
                getBankName(institutionId: institutionId, accessToken: accessToken, totalBalance: totalBalance)

                print("Account balance fetched: \(totalBalance) \(institutionId)")
                
            } catch let error {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func getBrokerAccount(accessToken: String) {
        var totalBalance = 0.0
        let url = URL(string: "https://sandbox.plaid.com/accounts/get")!
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
                
                getBrokerName(institutionId: institutionId, accessToken: accessToken, totalBalance: totalBalance)

                print("Account balance fetched: \(totalBalance) \(institutionId)")
                
            } catch let error {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func getBrokerName(institutionId: String, accessToken: String, totalBalance: Double) {
        let url = URL(string: "https://sandbox.plaid.com/institutions/get_by_id")!
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
                print(institutionName) // Do something with the institution name, e.g. return it or store it in a variable
                //pm.addBankAccount(institutionId: institutionId, accessToken: accessToken, institutionName: institutionName, totalBalance: totalBalance)
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }
    
    func getBankName(institutionId: String, accessToken: String, totalBalance: Double) {
        let url = URL(string: "https://sandbox.plaid.com/institutions/get_by_id")!
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
                print(institutionName) // Do something with the institution name, e.g. return it or store it in a variable
//                pm.addBankAccount(institutionId: institutionId, accessToken: accessToken, institutionName: institutionName, totalBalance: totalBalance)
                
                getBankTransactions(institutionId: institutionId, accessToken: accessToken, totalBalance: totalBalance, institutionName: institutionName)

            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }

    func getBankTransactions(institutionId: String, accessToken: String, totalBalance: Double, institutionName: String) {
        let url = URL(string: "https://sandbox.plaid.com/transactions/get")!
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
                "count": 100,
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
                                
                var transactions: [Transaction] = []
                
                for transactionData in transactionsData {
                    if let amount = transactionData["amount"] as? Double,
                       let dateTime = transactionData["date"] as? String,
                       let name = transactionData["merchant_name"] as? String {
                        let formattedAmount = String(amount)
                        let transaction = Transaction(amount: formattedAmount, merchant: name, dateTime: dateTime)
                        transactions.append(transaction)
                    }
                }
                pm.addBankAccount(institutionId: institutionId, accessToken: accessToken, institutionName: institutionName, totalBalance: totalBalance, transactions: transactions)
                
            } catch {
                print("Error getting trasactions: \(error)")
            }
            
        }
        task.resume()
        //print("list of transactions \(transactions)")
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }


    
}
