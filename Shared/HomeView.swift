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
                            Text("Portfolio:")
                                .bold()
                                .foregroundColor(.primary)
                                .font(.system(size: UIScreen.main.bounds.height * 0.047))
                                .padding(.top)
                            Text("$" + pm.totalNetWorth.withCommas())
                                .bold()
                                .font(.system(size: UIScreen.main.bounds.height * 0.09))
                                .scaledToFit()
                                .minimumScaleFactor(0.01)
                                .lineLimit(1)
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
                                    .font(.system(size: UIScreen.main.bounds.height * 0.039))
                            }
                            .buttonStyle(HapticButtonStyle())
                            Spacer()
                                .frame(maxHeight: UIScreen.main.bounds.height * 0.12)
                        }
                    }
                    .padding(.horizontal)
                    Divider()
                        .overlay(.gray)
                        .padding(.horizontal)
                    
                    List{
                        BankAccountsListView()
                            .listRowBackground(Color.gray.opacity(0.2))
                        BrokerAccountsListView()
                            .listRowBackground(Color.gray.opacity(0.2))
                        PropertiesListView()
                            .listRowBackground(Color.gray.opacity(0.2))
                    }
                    .scrollContentBackground(.hidden)
                    .refreshable {
                        pm.updateAccounts()
                        print("refresh")
                    }
                    .scrollIndicators(.hidden)
                    .environment(\.defaultMinListRowHeight, 49)
                    
                    HStack{
                        Button(action: {
                            self.showSteve = true
                        }) {
                            HStack{
                                Spacer()
                                Text("Talk with Steve 👨‍💼")
                                    .font(.system(size: UIScreen.main.bounds.height * 0.036))
                                    .padding()
                                    .foregroundColor(.primary)
                                    .bold()
                                    
                                Spacer()
                            }
                            .background(
                                ZStack{
                                    Color.primary.colorInvert()
                                    Color.gray.opacity(0.3)
                                }
                            )
                            .cornerRadius(32)
                        }
                        .buttonStyle(HapticButtonStyle())
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    .background(.gray.opacity(0.15))
                }
        }
        .fullScreenCover(isPresented: $showSteve){
            ChatView(vm: vm)
                .buttonStyle(HapticButtonStyle())
        }
        .fullScreenCover(isPresented: self.$showAccount){
            AccountView()
                .presentationDragIndicator(.visible)
                .buttonStyle(HapticButtonStyle())
        }
        .environmentObject(StoreVM())
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
