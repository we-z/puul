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
    @State private var toBeDeleted: IndexSet?
    @State private var showingDeleteAlert = false
    @State public var showLink = false
    @EnvironmentObject var storeVM: StoreVM
    @State private var showSubscriptions = false
    
    var body: some View {
            Section{
                VStack{
                    HStack{
                        Image(systemName: "building.2.fill")
                        Text("Stocks / ETFs")
                        Spacer()
                    }
                    .padding(.top, 6)
                    .font(.system(size: 30))
                    .bold()
                    .listRowSeparator(.hidden)
                    Divider()
                }
                .listRowSeparator(.hidden)
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
                                            .font(.system(size: 45))
                                            .bold()
                                        Spacer()
                                    }
                                    Divider()
                                        .padding(.top, 18)
                                }
                            }
                        }
                        .sheet(item: $accountPage){ rs in
                            BrokerAccountDetailsView(viewdata: rs)
                        }
                        .alert(isPresented: self.$showingDeleteAlert) {
                            Alert(title: Text("Are you sure?"),
                                  message: Text("All data associated with this account will be permenantly deleted"),
                                  primaryButton: .destructive(Text("Delete")) {
                                pm.deleteBrokerAccount(indexSet: toBeDeleted!)
                                self.toBeDeleted = nil
                            }, secondaryButton: .cancel() {
                                self.toBeDeleted = nil
                            }
                            )
                        }
                    }
                    .onDelete(perform: deleteRow)
                    .listRowSeparator(.hidden)
                
                    Button(action: {
//                        if !storeVM.hasUnlockedPro {
//                            self.showSubscriptions = true
//                        } else {
                            pm.createBrokerLinkToken()
                            print("Broker Menu")
                            //isBank = false
                            showLink = true
                        //}
                    }) {
                        HStack{
                            Spacer()
                            Image(systemName: "plus")
                                .font(.system(size: 30))
                                .padding(.bottom, 12)
                            Spacer()
                        }
                    }
            }
            .sheet(isPresented: self.$showLink,
                onDismiss: {
                    self.showLink = false
                pm.linkToken = ""
                }, content: {
                    PlaidLinkFlow(
                        showLink: showLink, isBank: false, pm: pm
                    )
                }
            )
            .fullScreenCover(isPresented: $showSubscriptions){
                SubscriptionView()
                    .buttonStyle(HapticButtonStyle())
            }
            .environmentObject(storeVM)
            
    }
    func deleteRow(at indexSet: IndexSet) {
        self.toBeDeleted = indexSet           // store rows for delete
        self.showingDeleteAlert = true
    }
}

struct BrokerAccountsListView_Previews: PreviewProvider {
    static var previews: some View {
        BrokerAccountsListView()
            .environmentObject(PlaidModel())
            .environmentObject(StoreVM())
    }
}
