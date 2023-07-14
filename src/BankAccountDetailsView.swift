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
                        .scaledToFit()
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                        .bold()
                        .font(.system(size: 69))
                    
                }
                .padding()
                Spacer()
            }
            List{
                ForEach(viewdata.sub_accounts) { subaccount in
                    Section(header:
                                VStack{
                        HStack{
                            HStack{
                                Text(subaccount.account_name)
                                    .padding(.trailing)
                                Spacer()
                            }
                            .font(.system(size: UIScreen.main.bounds.width * 0.05))
                            VStack{
                                Spacer()
                                Text("$" + subaccount.sub_balance.withCommas())
                                    .scaledToFit()
                                    .minimumScaleFactor(0.01)
                                    .lineLimit(1)
                                Spacer()
                            }
                            .font(.system(size: UIScreen.main.bounds.width * 0.069))
                        }
                        .bold()
                        .foregroundColor(.primary)
                        .offset(y: 23)
                        Divider()
                            .overlay(.gray)
                            .padding(.vertical)
                    }
                        
                    ){
                        ForEach(subaccount.transactions) { transaction in
                            HStack{
                                VStack(alignment: .leading, spacing: 6){
                                    Text(transaction.merchant)
                                        .bold()
                                        .font(.system(size: UIScreen.main.bounds.width * 0.05))
                                    Text(transaction.dateTime)
                                }
                                Spacer()
                                if transaction.amount > 0 {
                                    Text("-$" + abs(transaction.amount).withCommas())
                                        .bold()
                                        .font(.system(size: UIScreen.main.bounds.width * 0.066))
                                        .foregroundColor(.red)
                                } else {
                                    Text("+$" + abs(transaction.amount).withCommas())
                                        .bold()
                                        .font(.system(size: UIScreen.main.bounds.width * 0.066))
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                    
                }
                
            }
            .listStyle(SidebarListStyle())
            .accentColor(.primary)
                
            //}
        }
    }
}

struct BankAccountDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        BankAccountDetailsView(viewdata: BankAccount(institution_id: "String", access_token: "String",
                                                     institution_name: "Chase", balance: 64234.39, sub_accounts:
            [
                BankSubAccount(account_id: "String", account_name: "Plaid savings", sub_balance: 568.89, transactions: [
                    BankTransaction(amount: -746.45, merchant: "Apple", dateTime: "String"),
                    BankTransaction(amount: 37, merchant: "Uber", dateTime: "String"),
                    BankTransaction(amount: 46, merchant: "Sweet Greens", dateTime: "String"),
                    BankTransaction(amount: 920, merchant: "Zara", dateTime: "String"),
                    BankTransaction(amount: 43, merchant: "Tea Spoon", dateTime: "String")
                ]),
                
                BankSubAccount(account_id: "String", account_name: "Advantage savings account", sub_balance: 568.89, transactions: [
                    BankTransaction(amount: -746.45, merchant: "Apple", dateTime: "String"),
                    BankTransaction(amount: 37, merchant: "Uber", dateTime: "String"),
                    BankTransaction(amount: 46, merchant: "Sweet Greens", dateTime: "String"),
                    BankTransaction(amount: 920, merchant: "Zara", dateTime: "String"),
                    BankTransaction(amount: 43, merchant: "Tea Spoon", dateTime: "String")
                ])
                
            ]))
    }
}



