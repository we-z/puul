//
//  HomeView.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 4/26/23.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject var vm = ChatViewModel(api: ChatGPTAPI())
    @State private var showLink = false
    @State private var showAccount = false
    @State private var showSteve = false
    @EnvironmentObject var pm: PlaidModel
        
    var body: some View {
        NavigationStack{
                VStack(spacing: 0){
                    HStack{
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Portfolio")
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
                        Spacer()
                        VStack{
                            Button(action: {
                                self.showAccount = true
                            }) {
                                Image(systemName: "person.crop.circle")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 30))
                            }
                            .buttonStyle(HapticButtonStyle())
                            Spacer()
                                .frame(maxHeight: UIScreen.main.bounds.height * 0.11)
                        }
                    }
                    .padding(.horizontal)
                    .background(.primary.opacity(0.075))
                    
                    List{
                        BankAccountsListView()
                        BrokerAccountsListView()
                        PropertiesListView()
                            
                    }
                    .refreshable {
                        pm.updateAccounts()
                        print("refresh")
                    }
                    
                    HStack{
                        Button(action: {
                            self.showSteve = true
                        }) {
                            HStack{
                                Spacer()
                                Text("Talk with Steve")
                                    .padding()
                                    .foregroundColor(.primary)
                                    .bold()
                                    
                                Spacer()
                            }
                            .background(
                                ZStack{
                                    Color.primary.colorInvert()
                                    Color.primary.opacity(0.12)
                                }
                            )
                            .cornerRadius(32)
                        }
                        .buttonStyle(HapticButtonStyle())
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    .background(.primary.opacity(0.075))
                }
        }
        .fullScreenCover(isPresented: $showSteve){
            ChatView(vm: vm)
                .buttonStyle(HapticButtonStyle())
        }
        .sheet(isPresented: self.$showAccount,
            onDismiss: {
                self.showAccount = false
            }, content: {
                AccountView()
                    .presentationDragIndicator(.visible)
                    .buttonStyle(HapticButtonStyle())
            }
        )
        .sheet(isPresented: self.$showLink,
            onDismiss: {
                self.showLink = false
            }, content: {
                AssetPickerView()
                    .presentationDetents([.fraction(0.39)])
                    .presentationDragIndicator(.visible)
                    .buttonStyle(HapticButtonStyle())
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
