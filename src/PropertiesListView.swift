//
//  PropertiesListView.swift
//  Puul
//
//  Created by Wheezy Salem on 6/19/23.
//

import SwiftUI

struct PropertiesListView: View {
    @State public var showPropertySearch = false
    @EnvironmentObject var storeVM: StoreVM
    @State private var showSubscriptions = false
    @State private var showAlert = false
    
    var body: some View {
        Section{
            VStack{
                HStack{
                    Image(systemName: "house.fill")
                    Text("Real Estate")
                    Spacer()
                }
                .font(.system(size: 27))
                .bold()
                .padding(.top, 6)
                Divider()
                Button(action: {
//                   if storeVM.hasUnlockedPro {
//                     self.showPropertySearch = true
//                   } else {
//                       showSubscriptions = true
//                   }
                    showAlert = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 27))
                        .padding(3)
                }
                .accentColor(.primary)
            }
        }
        .sheet(isPresented: $showPropertySearch) {
            SearchPropertiesView()
        }
        .fullScreenCover(isPresented: $showSubscriptions){
            SubscriptionView()
                .buttonStyle(HapticButtonStyle())
        }
        .alert("Real Estate coming Soon", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

struct PropertiesListView_Previews: PreviewProvider {
    static var previews: some View {
        PropertiesListView()
            .environmentObject(StoreVM())
    }
}
