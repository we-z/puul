//
//  XCAChatGPTApp.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import SwiftUI

@main
struct PuulApp: App {
    
    @StateObject public var appModel: AppModel = AppModel()
    @StateObject var plaidModel: PlaidModel = PlaidModel()
    @StateObject private var storeVM = StoreVM()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
                    .preferredColorScheme(appModel.isLightMode ? .light : .dark)
                    .buttonStyle(HapticButtonStyle())
                    .onAppear{
                        plaidModel.updateAccounts()
                    }
                    .task {
                        await storeVM.updatePurchasedProducts()
                    }
            }
            .environmentObject(StoreVM())
            .environmentObject(appModel)
            .environmentObject(plaidModel)
            .accentColor(.primary)
        }
    }
}
