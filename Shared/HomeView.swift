//
//  HomeView.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 4/26/23.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject var vm = ViewModel(api: ChatGPTAPI(apiKey: "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"))
    @State private var showLink = false
    @State private var showSteve = false
    @EnvironmentObject var pm: PlaidModel
    
    var body: some View {
        NavigationStack{
                VStack(spacing: 0){
                    VStack(alignment: .leading, spacing: 6) {
                        HStack{
                            Text("Puul")
                                .bold()
                                .foregroundColor(.primary)
                                .font(.largeTitle)
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
                    .background(.primary.opacity(0.03))
                    
                    List{
                        if !pm.bankAccounts.isEmpty{
                            BankAccountsListView()
                        }
                        if !pm.brokerAccounts.isEmpty{
                            BrokerAccountsListView()
                        }
                    }
                    .refreshable {
                        print("refresh")
                    }
                    .background(.primary.opacity(0.11))
                    .scrollContentBackground(.hidden)
                        
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
                                Color.primary.opacity(0.12)
                            }
                        )
                        .cornerRadius(32)
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    .background(.primary.opacity(0.03))
                }
        }
        .fullScreenCover(isPresented: $showSteve){
            ContentView(vm: vm)
        }
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
    }
}
