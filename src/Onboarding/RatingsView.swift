//
//  RatingsView.swift
//  Puul
//
//  Created by Wheezy Capowdis on 2/5/25.
//

import SwiftUI

let hapticManager = HapticManager.instance

class HapticManager {
    static let instance = HapticManager()
    private init() {}

    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

struct RatingsView: View {
    
    @Environment(\.displayScale) var displayScale
    
    // Animated progress values start at 0.
    @State private var overallValue: Double = 0
    @State private var totalNetWorthValue: Double = 0
    @State private var creditScoreValue: Double = 0
    @State private var portfolioDiversityValue: Double = 0
    @State private var debtToIncomeValue: Double = 0
    @State private var retirementReadinessValue: Double = 0
    @State var shareSheetIsPresented: Bool = false
    
    private func statsView() -> some View {
        VStack {
            Image(systemName: "chart.bar.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.bottom)
            
            // Overall ProgressView (Total = 100)
            HStack {
                VStack(alignment: .leading) {
                    Text("Overall")
                        .bold()
                    Text("\(Int(overallValue))")
                        .font(.largeTitle)
                        .bold()
                    ProgressView(value: overallValue, total: 100)
                        .progressViewStyle(SolidProgressViewStyle(fillColor: .primary))
                }
                .padding()
                
                // Total Net Worth (Total = 1,000,000)
                VStack(alignment: .leading) {
                    Text("Total Net Worth")
                        .bold()
                    Text("$\(Int(totalNetWorthValue))")
                        .font(.largeTitle)
                        .bold()
                    ProgressView(value: totalNetWorthValue, total: 1_000_000)
                        .progressViewStyle(SolidProgressViewStyle(fillColor: .primary))
                }
                .padding()
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            
            // Credit Score (Total = 850)
            HStack {
                VStack(alignment: .leading) {
                    Text("Credit Score")
                        .bold()
                    Text("\(Int(creditScoreValue))")
                        .font(.largeTitle)
                        .bold()
                    ProgressView(value: creditScoreValue, total: 850)
                        .progressViewStyle(SolidProgressViewStyle(fillColor: .primary))
                }
                .padding()
                
                // Portfolio Diversity (Total = 100)
                VStack(alignment: .leading) {
                    Text("Portfolio Diversity")
                        .bold()
                    Text("\(Int(portfolioDiversityValue))")
                        .font(.largeTitle)
                        .bold()
                    ProgressView(value: portfolioDiversityValue, total: 100)
                        .progressViewStyle(SolidProgressViewStyle(fillColor: .primary))
                }
                .padding()
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            
            // Debt to Income Ratio (Total = 100)
            HStack {
                VStack(alignment: .leading) {
                    Text("Debt to Income Ratio")
                        .bold()
                    Text("\(Int(debtToIncomeValue))")
                        .font(.largeTitle)
                        .bold()
                    ProgressView(value: debtToIncomeValue, total: 100)
                        .progressViewStyle(SolidProgressViewStyle(fillColor: .primary))
                }
                .padding()
                
                // Retirement Readiness (Total = 100)
                VStack(alignment: .leading) {
                    Text("Retirement Readiness")
                        .bold()
                    Text("\(Int(retirementReadinessValue))")
                        .font(.largeTitle)
                        .bold()
                    ProgressView(value: retirementReadinessValue, total: 100)
                        .progressViewStyle(SolidProgressViewStyle(fillColor: .primary))
                }
                .padding()
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
                
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    statsView()
                }
                // Removed .colorInvert() from here because it can cause unexpected color changes
                Button {
                    shareSheetIsPresented = true
                } label: {
                    HStack {
                        Text("Share")
                        Image(systemName: "square.and.arrow.up")
                    }
                    .bold()
                    .font(.title2)
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
            .navigationTitle("My Financial Stats")
        }
        .onAppear {
            hapticManager.notification(type: .error)
            // Load persisted SurveyAnswers
            if let answers = SurveyPersistenceManager.loadAnswers() {
                // --- Credit Score ---
                // Use the credit score directly (max 850)
                let targetCreditScore = Double(answers.creditScore)
                
                // --- Total Net Worth ---
                // Use the total net worth directly (max 1,000,000)
                let targetNetWorth = Double(answers.totalNetWorth)
                
                // --- Portfolio Diversity ---
                // Assume there are 9 possible asset types.
                // The percentage is the count of owned assets scaled to 100.
                let maxAssets = 9.0
                let targetPortfolioDiversity = min((Double(answers.ownedAssets.count) / maxAssets) * 100, 100)
                
                // --- Debt to Income Ratio ---
                // A lower debt relative to salary is better.
                // We compute a rating where 0 debt gives 100 and debt equal to annual salary gives 0.
                let annualSalary = Double(answers.salary)
                let debt = Double(answers.debtAmount)
                let calculatedDTI: Double = annualSalary > 0 ? max(0, 100 - (debt / annualSalary * 100)) : 0
                let targetDebtToIncome = min(calculatedDTI, 100)
                
                // --- Retirement Readiness ---
                // Estimate the retirement corpus by calculating:
                //   estimatedCorpus = savingMonthly × 12 × (65 – age)
                // Then, scale that to a maximum target of 1,000,000 (capped at 100).
                let yearsToRetirement = max(65 - answers.age, 0)
                let estimatedCorpus = Double(answers.savingMonthly) * 12 * Double(yearsToRetirement)
                let targetRetirementReadiness = min((estimatedCorpus / 1_000_000) * 100, 100)
                
                // --- Overall ---
                // Overall is computed as the average of five metrics (all scaled to 100):
                //   1. Credit Score Percentage = (creditScore / 850 * 100)
                //   2. Net Worth Percentage = (totalNetWorth / 1_000_000 * 100)
                //   3. Portfolio Diversity (already percentage)
                //   4. Debt to Income (already percentage)
                //   5. Retirement Readiness (already percentage)
                let creditScorePercent = targetCreditScore / 850 * 100
                let netWorthPercent = targetNetWorth / 1_000_000 * 100
                let targetOverall = (creditScorePercent + targetPortfolioDiversity + targetDebtToIncome + targetRetirementReadiness + netWorthPercent) / 5
                
                // Animate all values from 0 to their target values.
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        creditScoreValue = targetCreditScore
                        totalNetWorthValue = targetNetWorth
                        portfolioDiversityValue = targetPortfolioDiversity
                        debtToIncomeValue = targetDebtToIncome
                        retirementReadinessValue = targetRetirementReadiness
                        overallValue = targetOverall
                    }
                }
            }
        }
        .sheet(isPresented: $shareSheetIsPresented, content: {
            if let data = render() {
                ShareView(activityItems: [data])
                    .ignoresSafeArea()
            }
        })
    }
    
    @MainActor
    private func render() -> UIImage? {
        let renderer = ImageRenderer(content: statsView())
        renderer.scale = displayScale
        // Nonlinear color mode can sometimes produce environment-based color changes.
        // Try .extendedLinear if .nonLinear still picks up accent colors:
        renderer.colorMode = .extendedLinear
        return renderer.uiImage
    }
}

// A custom ProgressViewStyle that never uses the system accent color,
// ensuring a consistent fill in any environment:
struct SolidProgressViewStyle: ProgressViewStyle {
    var fillColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(Color.secondary.opacity(0.3))
                    .frame(height: 9)
                
                // Filled portion
                if let fraction = configuration.fractionCompleted {
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundColor(fillColor)
                        .frame(width: geometry.size.width * CGFloat(fraction),
                               height: 9)
                }
            }
        }
        .frame(height: 8)
    }
}

struct RatingsView_Previews: PreviewProvider {
    static var previews: some View {
        RatingsView()
    }
}

struct ShareView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        activityViewController.completionWithItemsHandler = { _, completed, _, _ in
            // Handle completion here
            if completed {
                print("Share completed successfully!")
            } else {
                print("User canceled the share.")
            }
        }
        return activityViewController
    }

    func updateUIViewController(_: UIActivityViewController,
                                context _: UIViewControllerRepresentableContext<ShareView>)
    {
        // no-op
    }
}
