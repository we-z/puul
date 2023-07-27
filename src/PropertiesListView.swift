//
//  PropertiesListView.swift
//  Puul
//
//  Created by Wheezy Salem on 6/19/23.
//

import SwiftUI

struct PropertiesListView: View {
    @State public var showProperties = false
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
    //                if storeVM.purchasedSubscriptions.isEmpty {
    //                    self.showSubscriptions = true
    //                } else {
                        self.showProperties = true
                    //}
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 27))
                        .padding(3)
                }
                .accentColor(.primary)
            }
        }
        .alert("Real Estate coming Soon", isPresented: $showProperties) {
            Button("OK", role: .cancel) { }
        }
    }
}

struct PropertiesListView_Previews: PreviewProvider {
    static var previews: some View {
        PropertiesListView()
    }
}
