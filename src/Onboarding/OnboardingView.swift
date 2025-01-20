//
//  OnboardingView.swift
//  Hushpost
//
//  Created by Wheezy Capowdis on 12/30/24.
//

import SwiftUI
import StoreKit

struct OnboardingView: View {
    @EnvironmentObject var storeVM: StoreVM
    // MARK: - Internal model for each onboarding page
    struct OnboardingPage {
        let systemName: String
        let title: String
        let description: String
    }
    
    @State private var tabSelection: Int = 0
    @State var done: Bool = false
    
    // MARK: - Updated pages with SF Symbol icons, titles, and descriptions
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            systemName: "brain.head.profile",
            title: "AI Financial Advisor",
            description: "Leverage the power of AI to analyze your finances and provide expert guidance for smarter decisions."
        ),
        OnboardingPage(
            systemName: "chart.line.uptrend.xyaxis",
            title: "Financial Planning Made Simple",
            description: "Achieve your financial goals with personalized plans and actionable insights tailored to you."
        ),
        OnboardingPage(
            systemName: "lock.shield.fill",
            title: "Secure Wealth Management",
            description: "Keep your financial data and personal information safe with a locally running AI assistant"
        ),
        OnboardingPage(
            systemName: "hands.sparkles",
            title: "Help Us Make the World Wealthier",
            description: "Join our mission to make financial literacy and wealth management more accessible using AI."
        )
    ]
    
    var body: some View {
        VStack {
            // MARK: - Scrollable TabView
            TabView(selection: $tabSelection) {
                ForEach(pages.indices, id: \.self) { index in
                    VStack {
                        
                        
                        // Large SF Symbol icon
                        Image(systemName: pages[index].systemName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .padding()
                        
                        if index == pages.count - 1 {
                            HStack{
                                ForEach(0..<5, id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 45, height: 45) // Adjust the size as needed
                                        .foregroundColor(.yellow)
                                        
                                }
                            }
                            .padding()
                            
                        }
                        
                        // Title
                        Text(pages[index].title)
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                            
                            .padding()
                        
                        // Description
                        Text(pages[index].description)
                            .bold()
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding()
                            .padding(.horizontal)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            
            // MARK: - Next / Rate Us Button
            Button(action: {
                if tabSelection < pages.count - 1 {
                    // Move to the next page
                    tabSelection += 1
                } else {
                    // Implement your "Rate us" action here
                    if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                        DispatchQueue.main.async {
                            SKStoreReviewController.requestReview(in: scene)
                        }
                    }
                    withAnimation(.easeInOut) {
                        done = true
                    }
                }
            }) {
                Text(tabSelection == pages.count - 1 ? "Rate Us" : "Next")
                    .bold()
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.primary)
                    .colorInvert()
                    .background(.primary)
                    .cornerRadius(18)
                    .padding()
            }
            .buttonStyle(HapticButtonStyle())
        }
        .background(Color.primary.ignoresSafeArea().colorInvert())
        .animation(.spring, value: tabSelection)
        .offset(x: done ? -deviceWidth : 0)
        .onAppear {
            if storeVM.hasUnlockedPro {
                done = true
            } else {
                done = false
            }
        }
        .onChange(of: storeVM.hasUnlockedPro) { hasUnlockedPro in
            if hasUnlockedPro {
                done = true
            } else {
                done = false
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(StoreVM())
}
