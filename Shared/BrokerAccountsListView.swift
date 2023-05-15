//
//  BrokerAccountsListView.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 5/14/23.
//

import SwiftUI

struct BrokerAccountsListView: View {
    @EnvironmentObject var pm: PlaidModel
    @State var accountPage : BrokerAccount?
    
    var body: some View {
        Section(header: Text("Broker Accounts").bold().font(.system(size: 18)).padding(.bottom, 9)){
            ForEach(pm.brokerAccounts) { account in
                Button(action: {
                    accountPage = .init(institution_id: "String", access_token: "String", institution_name: account.institution_name, balance: account.balance, holdings: account.holdings)
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
                    //BankAccountDetailsView(viewdata: rs)
                    BrokerAccountDetailsView(viewdata: rs)
                }
            }
            .onDelete(perform: pm.deleteBrokerAccount)
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

struct BrokerAccountsListView_Previews: PreviewProvider {
    static var previews: some View {
        BrokerAccountsListView()
            .environmentObject(PlaidModel())
    }
}
