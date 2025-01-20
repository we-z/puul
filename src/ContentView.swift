//
//  ContentView.swift
//  Puul
//
//  Created by Wheezy Capowdis on 1/7/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var storeVM: StoreVM
    var body: some View {
        ZStack {
            HomeView()
            PaywallView()
                .environmentObject(StoreVM())
            if !storeVM.hasUnlockedPro {
                SurveyView()
                    .environmentObject(StoreVM())
            }
            InstallAIView()
            OnboardingView()
                .environmentObject(StoreVM())
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(StoreVM())
}
