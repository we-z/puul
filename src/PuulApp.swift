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
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
                    .preferredColorScheme(appModel.isLightMode ? .light : .dark)
                    .buttonStyle(HapticButtonStyle())
                    .onAppear{
                        plaidModel.updateAccounts()
                    }
                    .onChange(of: scenePhase) { newPhase in
                        if newPhase == .inactive {
                            print("Inactive")
                        } else if newPhase == .active {
                            plaidModel.updateAccounts()
                            print("Active")
                        } else if newPhase == .background {
                            print("Background")
                        }
                    }
            }
            .environmentObject(StoreVM())
            .environmentObject(appModel)
            .environmentObject(plaidModel)
            .accentColor(.primary)
        }
    }
}

