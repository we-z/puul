//
//  ContentView.swift
//  Puul
//
//  Created by Wheezy Capowdis on 1/7/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            HomeView()
            PaywallView()
                .environmentObject(StoreVM())
            SurveyView()
                .environmentObject(StoreVM())
            InstallAIView()
            OnboardingView()
                .environmentObject(StoreVM())
        }
    }
}

#Preview {
    ContentView()
}
