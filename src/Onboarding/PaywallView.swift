//
//  PaywallView.swift
//  Hushpost
//
//  Created by Wheezy Capowdis on 1/1/25.
//

import SwiftUI

struct PaywallView: View {
    @State var done: Bool = false
    // Features of the private photo-sharing app and their respective icons
    let featuresWithIcons = [
        ("Unlimited Questions", "message"),
        ("Tailored Financial Plans", "doc.text.fill"),
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
                    Text("Your Financial Ally")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    // Description
                    Text("Get personalized financial advice anywhere. Your money, your privacy.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    // Features
                    VStack {
                        ForEach(featuresWithIcons, id: \.0) { feature, icon in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 21, height: 21)
                                    .foregroundColor(.green)
                                    .padding(.trailing, 6)
                                Text(feature)
                                    .bold()
                                Spacer()
                                Image(systemName: icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 21, height: 21)
                                    .padding(.trailing, 6)
                                    .padding(.leading, 9)
                            }
                            .padding()
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(.secondary.opacity(0.2))
                    .cornerRadius(15)
                    .padding()
                }
            }
            .scrollIndicators(.hidden)
            VStack(spacing: 12) {
                Divider()
                    .shadow(color: .black, radius: 0.3)
                Button {
                    withAnimation(.easeInOut) {
                        done = true
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
                Text("Restore Purchase | Terms | Privacy")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            
        }
        .background(Color.primary.colorInvert().ignoresSafeArea())
        .offset(x: done ? -500 : 0)
    }
}

#Preview {
    PaywallView()
}
