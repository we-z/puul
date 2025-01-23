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
    @State var processing: Bool = false
    
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
        withAnimation(.easeInOut) {
            processing = true
        }
        do {
            try await storeVM.purchase(product)
            await storeVM.updatePurchasedProducts()
            if storeVM.success {
                withAnimation(.easeInOut) {
                    processing = false
                    done = true
                }
            }
            withAnimation(.easeInOut) {
                processing = false
            }
        } catch {
            print("purchase failed")
            processing = false
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack {
                    // Large SF Symbol icon
                    ZStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .padding()
                            .padding(.top, 90)
                    }
                    
                    // Title
                    HStack {
                        Text("Invest in Your Future")
                            .font(.largeTitle)
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
                HStack(spacing: 6) {
                    Button {
                        impactSoft.impactOccurred()
                        Task {
                            await storeVM.restoreProducts()
                        }
                    } label: {
                        Text("Restore Purchase")
                            .bold()
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    Text("|")
                        .foregroundColor(.gray)
                    Button {
                        impactSoft.impactOccurred()
                        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("Terms")
                            .bold()
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    Text("|")
                        .foregroundColor(.gray)
                    Button {
                        impactSoft.impactOccurred()
                        if let url = URL(string: "https://endlessfall-io.firebaseapp.com/privacy-policy/") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("Privacy")
                            .bold()
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                }
            }
            
        }
        .background {
            ZStack {
                Color.primary.colorInvert()
            }
            .ignoresSafeArea()
        }
        .overlay {
            if processing {
                ZStack {
                    Color.primary.opacity(0.2)
                    Rectangle()
                        .foregroundColor(.gray)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 90)
                        .cornerRadius(21)
                    ProgressView()
                        .tint(.white)
                        .controlSize(.large)
                }
                .ignoresSafeArea()
            }
        }
        .offset(x: done ? -deviceWidth : 0)
    }
}

#Preview {
    PaywallView()
        .environmentObject(StoreVM())
}
