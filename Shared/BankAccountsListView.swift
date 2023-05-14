//
//  BankAccountsListView.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 5/13/23.
//

import SwiftUI

struct BankAccountsListView: View {
    @EnvironmentObject var pm: PlaidModel
    @State var accountPage : BankAccount?
    
    var body: some View {
        Section(header: Text("Bank Accounts").bold().font(.system(size: 18)).padding(.bottom, 9)){
            ForEach(pm.bankAccounts) { account in
                Button(action: {
                    accountPage = .init(institution_id: "String", access_token: "String", institution_name: account.institution_name, balance: account.balance, transactions: account.transactions)
                }) {
                    HStack(spacing: 15){
                        VStack(spacing: 6) {
                            HStack {
                                Text(account.institution_name + ":")
                                    .font(.system(size: 27))
                                    .bold()
                                Spacer()
                            }
                            HStack {
                                Text("$" + account.balance.withCommas())
                                    .font(.system(size: 36))
                                Spacer()
                            }
                        }
                        .padding(.vertical)
                    }
                }
                .sheet(item: $accountPage){ rs in
                    BankAccountDetailsView(viewdata: rs)
                }
            }
            .onDelete(perform: pm.deleteBankAccount)
            .listRowBackground(
                ZStack{
                    Color.primary.colorInvert()
                    Color.primary.opacity(0.06)
                }
            )
        }
        .textCase(nil)
    }
}

struct BankAccountsListView_Previews: PreviewProvider {
    static var previews: some View {
        BankAccountsListView()
            .environmentObject(PlaidModel())
    }
}
