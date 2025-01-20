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
            if !storeVM.hasUnlockedPro {
                PaywallView()
                    .environmentObject(StoreVM())
                SurveyView()
                    .environmentObject(StoreVM())
                OnboardingView()
                    .environmentObject(StoreVM())
            }
            InstallAIView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(StoreVM())
}
