//
//  AssetPickerView.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 4/28/23.
//

import LinkKit
import SwiftUI

struct AssetPickerView: View {
    
    @EnvironmentObject var pm: PlaidModel
    @State public var showLink = false
    @State public var isBank = false {
        didSet{
            if isBank == true{
                pm.createBankLinkToken()
                print("Bank Menu")
            } else {
                pm.createBrokerLinkToken()
                print("Broker Menu")
            }
            showLink = true
        }
    }
    @State public var showProperties = false
    @State private var showSubscriptions = false
    @StateObject var storeVM = StoreVM()
        
    var body: some View {
        VStack(alignment: .leading,spacing: 18){
            Button(action: {
                if storeVM.purchasedSubscriptions.isEmpty {
                    self.showSubscriptions = true
                } else {
                    self.isBank = true
                }
            }) {
                HStack{
                    Image(systemName: "building.columns.fill")
                    Text("Bank account")
                    Spacer()
                }
                .padding()
                .background(.primary.opacity(0.15))
                .cornerRadius(15)
            }
            
            Button(action: {
                if storeVM.purchasedSubscriptions.isEmpty {
                    self.showSubscriptions = true
                } else {
                    self.isBank = false
                }
            }) {
                HStack{
                    Image(systemName: "building.2.fill")
                    Text("Brokerage / investing")
                    Spacer()
                }
                .padding()
                .background(.primary.opacity(0.15))
                .cornerRadius(15)
            }
            Button(action: {
                if storeVM.purchasedSubscriptions.isEmpty {
                    self.showSubscriptions = true
                } else {
                    self.showProperties = true
                }
            }) {
                HStack{
                    Image(systemName: "house.fill")
                    Text("Properties")
                    Spacer()
                }
                .padding()
                .background(.primary.opacity(0.15))
                .cornerRadius(15)
            }
            .alert("Properties coming Soon", isPresented: $showProperties) {
                Button("OK", role: .cancel) { }
            }
        }
        .padding()
        .font(.system(size: 30))
        .bold()
        .accentColor(.primary)
        .sheet(isPresented: self.$showLink,
            onDismiss: {
                self.showLink = false
            }, content: {
                PlaidLinkFlow(
                    showLink: $showLink, isBank: $isBank, pm: _pm
                )
            }
        )
        .fullScreenCover(isPresented: $showSubscriptions){
            SubscriptionView()
                //.buttonStyle(HapticButtonStyle())
        }
        .environmentObject(storeVM)
    }
}

struct AssetPickerView_Previews: PreviewProvider {
    static var previews: some View {
        AssetPickerView()
    }
}
