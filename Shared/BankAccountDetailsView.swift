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
                        .padding(.top)
                    Text("$" + viewdata.balance.withCommas())
                        .bold()
                        .font(.system(size: 69))
                    
                }
                .padding()
                Spacer()
            }
            if viewdata.transactions.isEmpty{
                List{
                    Section(header: Text("No Transactions Found").font(.system(size: 40))){
                    }
                }
            } else {
                List{
                    Section(header: Text("Latest Transactions").bold().padding(.bottom, 9).font(.system(size: 20))){
                        ForEach(viewdata.transactions) { transaction in
                            HStack{
                                VStack(alignment: .leading, spacing: 6){
                                    Text(transaction.merchant)
                                        .bold()
                                        .font(.system(size: 21))
                                    Text(transaction.dateTime)
                                }
                                Spacer()
                                Text("$" + transaction.amount.withCommas())
                                    .bold()
                                    .font(.system(size: 27))
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
        }
    }
}

struct BankAccountDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        BankAccountDetailsView(viewdata: BankAccount(institution_id: "String", access_token: "String", institution_name: "Chase", balance: 0, transactions:
                [
                    BankTransaction(amount: 746, merchant: "Apple", dateTime: "String"),
                    BankTransaction(amount: 37, merchant: "Uber", dateTime: "String"),
                    BankTransaction(amount: 46, merchant: "Sweet Greens", dateTime: "String"),
                    BankTransaction(amount: 920, merchant: "Zara", dateTime: "String"),
                    BankTransaction(amount: 43, merchant: "Tea Spoon", dateTime: "String")
                ]))
    }
}


