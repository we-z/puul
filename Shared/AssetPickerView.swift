//
//  AssetPickerView.swift
//  XCAChatGPT
//
//  Created by Wheezy Salem on 4/28/23.
//

import LinkKit
import SwiftUI

struct AssetPickerView: View {
    
    @State public var showLink = false
    @State public var isBank = false
    // it's either a bank or brokerage account 
    @EnvironmentObject var pm: PlaidModel
        
    var body: some View {
        VStack(alignment: .leading,spacing: 18){
            Button(action: {
                self.isBank = true
                self.showLink = true
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
            HStack{
                Image(systemName: "house.fill")
                Text("Properties")
                Spacer()
            }
            .padding()
            .background(.primary.opacity(0.15))
            .cornerRadius(15)
            Button(action: {
                self.isBank = false
                self.showLink = true
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
    }
}

struct AssetPickerView_Previews: PreviewProvider {
    static var previews: some View {
        AssetPickerView()
    }
}
