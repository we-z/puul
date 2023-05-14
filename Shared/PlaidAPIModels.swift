//
//  PlaidAPIModels.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 5/3/23.
//

import Foundation
import SwiftUI

class PlaidModel: ObservableObject {
    let bankAccountsKey: String = "accounts"
    let networthKey: String = "networth"
    @Published var totalNetWorth: Double = 0
    @Published var brokerAccounts: [BrokerAccount] = [] {
        didSet{
            saveAccounts()
        }
    }
    @Published var bankAccounts: [BankAccount] = [] {
        didSet{
            saveAccounts()
            print("List of bank accounts: \(bankAccounts)")
        }
    }
    
    init() {
        getBankAccounts()
        calculateNetworth()
    }
    
    func calculateNetworth() {
        totalNetWorth = 0
        bankAccounts.forEach { account in
            self.totalNetWorth += account.balance
        }
    }


    func deleteBankAccount(indexSet: IndexSet) {
        bankAccounts.remove(atOffsets: indexSet)
    }
    
    func getBankAccounts(){
        guard
            let accountData = UserDefaults.standard.data(forKey: bankAccountsKey),
            let savedAccounts = try? JSONDecoder().decode([BankAccount].self, from: accountData)
        else {return}
        
        self.bankAccounts = savedAccounts
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
    
    func saveAccounts() {
        if let data = try? JSONEncoder().encode(bankAccounts){
            UserDefaults.standard.set(data, forKey: bankAccountsKey)
        }
        self.calculateNetworth()
    }
    
}

extension Double {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
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
    var amount: String
    var merchant: String
    var dateTime: String
}

struct BrokerAccount: Identifiable, Encodable, Decodable {
    var id = UUID()
    var access_token: String
    var institution_name: String
    var balance: Double
    var holdings: [Security]
}

struct Security: Identifiable, Encodable, Decodable {
    var id = UUID()
    var ticker: String
    var name: String
    var closePrice: Double
}
