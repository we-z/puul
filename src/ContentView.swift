//
//  ContentView.swift
//  Puul
//
//  Created by Wheezy Capowdis on 1/7/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var storeVM: StoreVM
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        ZStack {
            HomeView()
            if !storeVM.hasUnlockedPro {
                PaywallView()
                    .environmentObject(StoreVM())
//                DemoView()
//                    .environmentObject(AIChatModel())
                if SurveyPersistenceManager.loadAnswers() == nil {
                    SurveyView()
                        .environmentObject(StoreVM())
                }
                OnboardingView()
                    .environmentObject(StoreVM())
                InstallAIView()
            }
        }
        .onChange(of: scenePhase) { _ in
            Task {
                await storeVM.requestProducts()
                await storeVM.updatePurchasedProducts()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(StoreVM())
}
