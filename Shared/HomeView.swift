//
//  HomeView.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 4/26/23.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject var vm = ViewModel(api: ChatGPTAPI())
    @State private var showLink = false
    @State private var showAccount = false
    @State private var showSteve = false
    @EnvironmentObject var pm: PlaidModel
    
    var body: some View {
        NavigationStack{
                VStack(spacing: 0){
                    VStack(alignment: .leading, spacing: 6) {
                        HStack{
                            Button(action: {
                                self.showAccount = true
                            }) {
                                Image(systemName: "person.crop.circle")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 30))
                            }
                            Spacer()
                            Button(action: {
                                self.showLink = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 30))
                            }
                        }
                        
                        Text("Total net worth")
                            .bold()
                            .foregroundColor(.primary)
                            .font(.system(size: 30))
                            .opacity(0.7)
                            .padding(.top)
                        Text("$" + pm.totalNetWorth.withCommas())
                            .bold()
                            .foregroundColor(.primary)
                            .font(.system(size: 75))
                        Spacer()
                            .frame(maxHeight: 21)
                    }
                    .padding(.horizontal)
                    .background(.primary.opacity(0.1))
                    
                    if !pm.bankAccounts.isEmpty || !pm.brokerAccounts.isEmpty {
                        List{
                            if !pm.bankAccounts.isEmpty{
                                BankAccountsListView()
                            }
                            if !pm.brokerAccounts.isEmpty{
                                BrokerAccountsListView()
                            }
                        }
                        .refreshable {
                            pm.updateAccounts()
                            print("refresh")
                        }
                        .scrollContentBackground(.hidden)
                    } else {
                        VStack {
                            HStack{
                                Text("Press plus to add an asset class")
                                Spacer()
                                VStack{
                                    Image(systemName: "arrow.turn.right.up")
                                    Spacer()
                                        .frame(maxHeight: 120)
                                }
                            }
                            Spacer()
                            HStack{
                                Text("Ask Steve for financial advice")
                                Spacer()
                                VStack{
                                    Spacer()
                                        .frame(maxHeight: 120)
                                    Image(systemName: "arrow.turn.right.down")
                                }
                            }
                        }
                        .padding(.vertical)
                        .font(.system(size: UIScreen.main.bounds.width * 0.13))
                        .padding(.horizontal, 35)
                        Spacer()
                    }
                        
                    HStack{
                        Button(action: {
                            self.showSteve = true
                        }) {
                            Spacer()
                            Text("Chat with Steve")
                                .padding()
                            Spacer()
                        }
                        .foregroundColor(.primary)
                        .bold()
                        .background(
                            ZStack{
                                Color.primary.colorInvert()
                                Color.primary.opacity(0.18)
                            }
                        )
                        .cornerRadius(32)
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    .background(.primary.opacity(0.1))
                }
        }
        .fullScreenCover(isPresented: $showSteve){
            ChatView(vm: vm)
        }
        .sheet(isPresented: self.$showAccount,
            onDismiss: {
                self.showAccount = false
            }, content: {
                AccountView()
                    .presentationDragIndicator(.visible)
            }
        )
        .sheet(isPresented: self.$showLink,
            onDismiss: {
                self.showLink = false
            }, content: {
                AssetPickerView()
                    .presentationDetents([.fraction(0.39)])
                    .presentationDragIndicator(.visible)
            }
        )
        .accentColor(.primary)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(PlaidModel())
            .environmentObject(StoreVM())
    }
}
