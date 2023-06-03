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
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
                    .preferredColorScheme(appModel.isLightMode ? .light : .dark)
            }
            .environmentObject(appModel)
            .environmentObject(plaidModel)
            .accentColor(.primary)
        }
    }
}
