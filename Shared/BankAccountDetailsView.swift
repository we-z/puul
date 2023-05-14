//
//  AccountDetailsView.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 5/9/23.
//

import SwiftUI

struct BankAccountDetailsView: View {
    @State var viewdata: BankAccount
    var body: some View {
        VStack{
            HStack{
                VStack(alignment: .leading, spacing: 6){
                    Text(viewdata.institution_name + ":")
                        .bold()
                        .foregroundColor(.primary)
                        .font(.system(size: 36))
                        .opacity(0.7)
                        .padding(.top)
                    Text("$" + viewdata.balance.withCommas())
                        .bold()
                        .font(.system(size: 69))
                    
                }
                .padding()
                Spacer()
            }
            List{
                ForEach(viewdata.transactions) { transaction in
                    HStack{
                        VStack(alignment: .leading, spacing: 6){
                            Text(transaction.merchant)
                                .bold()
                                .font(.system(size: 21))
                            Text(transaction.dateTime)
                        }
                        Spacer()
                        Text("$" + transaction.amount)
                            .bold()
                            .font(.system(size: 27))
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}

struct BankAccountDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        BankAccountDetailsView(viewdata: BankAccount(institution_id: "String", access_token: "String", institution_name: "Chase", balance: 0, transactions: [Transaction(amount: "String", merchant: "String", dateTime: "String")]))
    }
}


