//
//  BankAccountsListView.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 5/13/23.
//

import SwiftUI

struct BankAccountsListView: View {
    @EnvironmentObject var pm: PlaidModel
    @State var accountPage: BankAccount?
    @State public var showLink = false
    @State private var toBeDeleted: IndexSet?
    @State private var showingDeleteAlert = false
    @EnvironmentObject var storeVM: StoreVM
    @State private var showSubscriptions = false

    var body: some View {
        Section {
            VStack {
                HStack {
                    Text("🏦")
                        .scaleEffect(1.2)
                        .offset(y: -3)
                    Text("Bank accounts")
                    Spacer()
                }
                .padding(.top, 6)
                .font(.system(size: 27))
                .bold()
                .listRowSeparator(.hidden)
                Divider()
            }
            .listRowSeparator(.hidden)
            ForEach(pm.bankAccounts) { account in

                Button(action: {
                    accountPage = .init(institution_id: "String", access_token: "String", institution_name: account.institution_name, balance: account.balance, sub_accounts: account.sub_accounts)
                }) {
                    VStack(spacing: 6) {
                        HStack {
                            Text(account.institution_name + ":")
                                .font(.system(size: 27))
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Text("$" + account.balance.withCommas())
                                .font(.system(size: 45))
                                .bold()
                            Spacer()
                        }
                        Divider()
                            .padding(.top, 18)
                    }
                }
                .sheet(item: $accountPage) { rs in
                    BankAccountDetailsView(viewdata: rs)
                }
                .alert(isPresented: self.$showingDeleteAlert) {
                    Alert(title: Text("Are you sure?"),
                          message: Text("All data associated with this account will be permenantly deleted"),
                          primaryButton: .destructive(Text("Delete")) {
                              pm.deleteBankAccount(indexSet: toBeDeleted!)
                              self.toBeDeleted = nil
                          }, secondaryButton: .cancel {
                              self.toBeDeleted = nil
                          })
                }
            }
            .onDelete(perform: deleteRow)
            .listRowSeparator(.hidden)

            Button(action: {
                if !storeVM.hasUnlockedPro, (pm.brokerAccounts.count + pm.bankAccounts.count) > 1 {
                    self.showSubscriptions = true
                } else {
                    pm.createBankLinkToken()
                    print("Bank Menu")
                    // isBank = true
                    showLink = true
                }
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "plus")
                        .font(.system(size: 27))
                        .padding(.bottom, 12)
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showLink,
               onDismiss: {
                   self.showLink = false
                   pm.linkToken = ""
               }, content: {
                   PlaidLinkFlow(
                       showLink: showLink,
                       isBank: true,
                       pm: pm
                   )
               })
        .fullScreenCover(isPresented: $showSubscriptions) {
            SubscriptionView()
                .buttonStyle(HapticButtonStyle())
        }
        .environmentObject(storeVM)
    }

    func deleteRow(at indexSet: IndexSet) {
        toBeDeleted = indexSet // store rows for delete
        showingDeleteAlert = true
    }
}

struct BankAccountsListView_Previews: PreviewProvider {
    static var previews: some View {
        BankAccountsListView()
            .environmentObject(PlaidModel())
            .environmentObject(StoreVM())
    }
}
