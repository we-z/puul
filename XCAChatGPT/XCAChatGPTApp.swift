//
//  XCAChatGPTApp.swift
//  XCAChatGPT
//
//  Created by Alfian Losari on 01/02/23.
//

import SwiftUI

@main
struct XCAChatGPTApp: App {
    
    @StateObject var vm = ViewModel(api: ChatGPTAPI(apiKey: "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"))
    @StateObject var plaidModel: PlaidModel = PlaidModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .environmentObject(plaidModel)
            .accentColor(.primary)
        }
    }
}
