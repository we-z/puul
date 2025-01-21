//
//  PaywallView.swift
//  Hushpost
//
//  Created by Wheezy Capowdis on 1/1/25.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var storeVM: StoreVM
    @State var done: Bool = false
    // Features of the private photo-sharing app and their respective icons
    let featuresWithIcons = [
        ("Tailored Financial Plans", "doc.text.fill"),
        ("Unlimited Questions", "message"),
        ("Expert Financial Advice", "brain.head.profile"),
        ("Access Anywhere", "globe"),
        ("Locally Running AI", "iphone"),
        ("Privacy-First AI", "lock.shield.fill"),
        ("No Tracking", "eye.slash.fill"),
        ("Secure Model", "checkmark.shield.fill"),
        ("Personalized Investment Strategizing", "chart.bar.fill"),
        ("AI Market Insights", "eye.fill"),
        ("Tax Optimization Guidance", "percent"),
        ("Budgeting Assistance", "dollarsign.circle.fill"),
        ("Retirement Planning", "figure.walk"),
        ("Risk Assessment Methods", "exclamationmark.triangle.fill"),
        ("Portfolio Analysis", "chart.pie.fill"),
        ("Goal-Oriented Savings Plans", "target"),
        ("Crypto and Alternative Asset Insights", "bitcoinsign.circle.fill"),
        ("Debt Reduction Advice", "arrow.down.circle.fill"),
        ("Educational Content Library", "book.closed.fill"),
        ("Sustainable Investment Insight", "leaf.fill")
    ]
    
    func buy(product: Product) async {
        do {
            try await storeVM.purchase(product)
            await storeVM.updatePurchasedProducts()
            if storeVM.success {
                withAnimation(.easeInOut) {
                    done = true
                }
            }
        } catch {
            print("purchase failed")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack {
                    // Large SF Symbol icon
                    ZStack {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .cornerRadius(120)
                            .padding()
                    }
                    
                    // Title
                    HStack {
                        Text("Invest in Your Future.")
                            .font(.system(size: 30))
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding()
                            .padding()
//                        Spacer()
                    }
                    
                    // Features
                    VStack {
                        ForEach(featuresWithIcons, id: \.0) { feature, icon in
                            HStack {
                                Image(systemName: icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 27, height: 27)
                                    .padding(.horizontal)
                                Text(feature)
                                    .font(.system(size: 21))
                                    .bold()
                                Spacer()
                                
                            }
                            .padding()
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            VStack(spacing: 12) {
                Divider()
                    .shadow(color: .black, radius: 0.3)
                Button {
                    Task {
                        await buy(product: storeVM.subscriptions.first!)
                    }
                } label: {
                    Text("Continue for free")
                        .bold()
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.primary)
                        .colorInvert()
                        .background(Color.primary)
                        .cornerRadius(21)
                        .padding([.horizontal])
                }
                .buttonStyle(HapticButtonStyle())
                Text("1 month free trial, then $29.99 / month")
                    .font(.headline)
                Button {
                    impactSoft.impactOccurred()
                    Task {
                        try? await AppStore.sync()
                    }
                } label: {
                    Text("Restore Purchase")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            
        }
        .background {
            ZStack {
                Color.primary.colorInvert()
            }
            .ignoresSafeArea()
        }
        .offset(x: done ? -deviceWidth : 0)
    }
}

#Preview {
    PaywallView()
        .environmentObject(StoreVM())
}
