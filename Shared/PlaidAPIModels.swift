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
    @Published var totalNetWorth: Double = 0
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
        print(bankString)
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
        print(brokerString)
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
    
    func addBankAccount(institutionId: String, accessToken: String, institutionName: String, totalBalance: Double, transactions: [Transaction]){
        let newAccount = BankAccount(institution_id: institutionId, access_token: accessToken, institution_name: institutionName, balance: totalBalance, transactions: transactions)
        DispatchQueue.main.async {
            self.bankAccounts.append(newAccount)
        }
        
    }
    
    func addBrokerAccount(institutionId: String, accessToken: String, institutionName: String, totalBalance: Double, holdings: [Security]){
        let newAccount = BrokerAccount(institution_id: institutionId, access_token: accessToken, institution_name: institutionName, balance: totalBalance, holdings: holdings)
        DispatchQueue.main.async {
            self.brokerAccounts.append(newAccount)
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
    var transactions: [Transaction]
}

struct Transaction: Identifiable, Encodable, Decodable {
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
