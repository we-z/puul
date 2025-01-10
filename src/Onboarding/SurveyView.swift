import SwiftUI

// MARK: - Model

/// Holds all the user's answers from the survey
struct SurveyAnswers {
    // Example numeric inputs
    var age: Int = 18
    var salary: Int = 50_000
    var creditScore: Int = 700
    var debtAmount: Int = 0
    var savingMonthly: Int = 0
    
    // Example multi-choice/single-choice
    var demographic: String = "Prefer not to say"
    var location: String = "United States"
    var riskTolerance: String = "Medium"
    var goals: [String] = []
    var hasAdvisor: String = "No"
    var advisor: String = "None"
    var employment: String = "Unemployed"
    var selectedIndustries: [String] = []
    var ownedAssets: [String] = []
    var filesOwnTaxes: String = "No"
    var taxTool: String = "None"
    var hasDebts: String = "No"
    
    // For final page financial status (placeholder logic)
    var financialStatus: String = "Dependent"
}

/// ViewModel to manage the steps and hold user answers
class SurveyViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var answers = SurveyAnswers()
    
    // Steps in the survey
    let totalSteps = 14  // We'll use 0...13 for questions, 14 for final
    
    func nextStep() {
        if currentStep < totalSteps {
            withAnimation(.easeInOut) {
                currentStep += 1
            }
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    // Simple placeholder logic to determine a final "status"
    func determineFinancialStatus() {
        let monthlySaving = answers.savingMonthly
        let totalDebt = answers.debtAmount
        
        // Adjust these thresholds to reflect realistic scenarios
        if monthlySaving >= 10_000 && totalDebt <= 1_000 {
            answers.financialStatus = "Financially Free"
        } else if monthlySaving >= 5_000 && totalDebt < 20_000 {
            answers.financialStatus = "Stable"
        } else if monthlySaving >= 2_000 && totalDebt < 50_000 {
            answers.financialStatus = "Independent"
        } else {
            answers.financialStatus = "Dependent"
        }
    }
}

// MARK: - Root View

struct SurveyView: View {
    @StateObject private var surveyVM = SurveyViewModel()
    
    var body: some View {
        SurveyContainerView()
            .environmentObject(surveyVM)
    }
}

// MARK: - Survey Container

/// Switches between different survey questions based on the current step
struct SurveyContainerView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    @State private var done: Bool = false
    @State var showingAlert = false
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.label
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray4
    }
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    if surveyVM.currentStep > 0 {
                        withAnimation(.easeInOut) {
                            surveyVM.currentStep -= 1
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.title3)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                }
                
                Spacer()
                Button {
                    showingAlert = true
                } label: {
                    HStack {
                        Text("skip")
                    }
                    .font(.title3)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                }
                .buttonStyle(HapticButtonStyle())
            }
            .opacity(surveyVM.currentStep == 0 ? 0 : 1)
            // MARK: - Paging TabView for Survey Steps
            // MARK: - Paging TabView for Survey Steps
            TabView(selection: $surveyVM.currentStep) {
                IntroductionView()
                    .tag(0) // New introduction view as the first page
                
                AgeQuestionView()
                    .tag(1)
                
                //LocationQuestionView
                LocationQuestionView()
                    .tag(2)
                
                //EmploymentQuestionView
                EmploymentQuestionView()
                    .tag(3)
                
                //SalaryQuestionView
                SalaryQuestionView()
                    .tag(4)
                
                GoalQuestionView()
                    .tag(5)
                
                HumanAdvisorQuestionView()
                    .tag(6)
                
                //RiskToleranceQuestionView
                RiskToleranceQuestionView()
                    .tag(7)
                
                IndustriesQuestionView()
                    .tag(8)
                
                AssetsQuestionView()
                    .tag(9)
                
                FileTaxesQuestionView()
                    .tag(10)
                
                CreditScoreQuestionView()
                    .tag(11)
                
                DebtQuestionView()
                    .tag(12)
                
                SavingMonthlyQuestionView()
                    .tag(13)
                
                FinalStatusView()
                    .tag(14)
            }
            // Let users swipe between pages and show the page dots
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            // Animate changes in the current step
            .animation(.spring(), value: surveyVM.currentStep)
            
            Spacer()
            
            // MARK: - Next Button
            Button(action: {
                // If not on the final step, go next;
                // otherwise you could navigate away or do something else
                if surveyVM.currentStep < surveyVM.totalSteps {
                    if surveyVM.currentStep == 123{
                        // If about to go from step 13 -> 14, call logic for final status
                        surveyVM.determineFinancialStatus()
                    }
                    surveyVM.nextStep()
                } else {
                    withAnimation(.easeInOut) {
                        done = true
                    }
                }
            }) {
                Text(surveyVM.currentStep == surveyVM.totalSteps ? "Let's Plan for the Future" : "Next")
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
        .background(Color.primary.colorInvert())
        .offset(x: done ? -500 : 0)
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Are you sure?"),
                message: Text("This information helps Puul provide you with better services. All data is stored on your device, protecting your privacy."),
                primaryButton: .destructive(Text("Skip"), action: {
                    withAnimation(.easeInOut) {
                        done = true
                    }
                }),
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
    }
}

// MARK: - Common Survey Navigation

/// A common header with a back button (top-left)
struct SurveyNavigationHeader: View {
    let title: String
    let onBack: () -> Void
    @EnvironmentObject var surveyVM: SurveyViewModel
    var body: some View {
        VStack{
            VStack{
                Text(title)
                    .bold()
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .frame(maxHeight: .infinity)
            .padding([.horizontal])
            Spacer()
        }
    }
}

/// A common footer with a next button (bottom)
struct SurveyNavigationFooter: View {
    let nextDisabled: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack {
            Text(" ")
                .padding()
        }
    }
}

// MARK: - Helper Views for Single and Multi Selection

/// A simple single-selection list
struct SingleChoiceList: View {
    let choices: [String]
    @Binding var selection: String
    
    var body: some View {
        Picker("", selection: $selection) {
            ForEach(choices, id: \.self) { choice in
                Text(choice).tag(choice)
            }
        }
        .pickerStyle(WheelPickerStyle())
    }
}

/// A simple multi-selection list
struct MultiChoiceList: View {
    let choices: [String]
    @Binding var selections: [String]
    
    var body: some View {
        VStack {
            Text("Multiple Selection")
                .font(.headline)
            List(choices, id: \.self) { choice in
                HStack {
                    Text(choice)
                    Spacer()
                    if selections.contains(choice) {
                        Image(systemName: "checkmark")
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selections.contains(choice) {
                        // remove
                        selections.removeAll(where: { $0 == choice })
                    } else {
                        // add
                        selections.append(choice)
                    }
                }
            }
            .listStyle(.plain)
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - QUESTION VIEWS

// 0: Introduction
struct IntroductionView: View {
    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .cornerRadius(120)
                .padding()
            Text("Client Questionnaire")
                .font(.largeTitle)
                .bold()
                .padding()
            
            Text("The following questions help Puul create your financial plan based on your needs and goals.")
                .font(.title3)
                .bold()
                .multilineTextAlignment(.center)
                .padding()
            HStack {
                Image(systemName: "clock")
                Text("Takes 1 minute")
            }
            .bold()
            .padding()
            Spacer()
        }
    }
}

// 0: Age
struct AgeQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "What's your Age?") {
                surveyVM.previousStep()
            }
            
            // Use a Picker for a scrolling number selector
            Picker("Select Age", selection: $surveyVM.answers.age) {
                ForEach(4..<101, id: \.self) { age in
                    Text("\(age)").tag(age)
                }
            }
            .pickerStyle(WheelPickerStyle())
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

// 1: Salary
struct SalaryQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "What's your Salary?") {
                surveyVM.previousStep()
            }
            
            // Convert the stride to an array for ForEach
            Picker("Select Salary (in thousands)", selection: $surveyVM.answers.salary) {
                ForEach(Array(stride(from: 0, through: 2_000_000, by: 5_000)), id: \.self) { salaryValue in
                    Text("$\(salaryValue)").tag(salaryValue)
                }
            }
            .pickerStyle(WheelPickerStyle())
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

// 2: Demographic
struct DemographicQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    let choices = [
        "Prefer not to say",
        "Gen Z",
        "Millennial",
        "Gen X",
        "Baby Boomer",
        "Other"
    ]
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "Demographic Group") {
                surveyVM.previousStep()
            }
            
            SingleChoiceList(choices: choices, selection: $surveyVM.answers.demographic)
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

// 3: Location
struct LocationQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    let choices = [
        "United States",
        "Canada",
        "Latin America",
        "Europe",
        "Middle East",
        "Africa",
        "Asia",
        "Other"
    ]
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "Your Location") {
                surveyVM.previousStep()
            }
            
            SingleChoiceList(choices: choices, selection: $surveyVM.answers.location)
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

// 4: Risk Tolerance
struct RiskToleranceQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    let choices = ["Super risk averse", "Low", "Medium", "High", "Super high risk"]
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "Risk Tolerance") {
                surveyVM.previousStep()
            }
            
            SingleChoiceList(choices: choices, selection: $surveyVM.answers.riskTolerance)
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

// 5: Goal
struct GoalQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    let choices = ["Buy a home", "Retire", "Grow investment portfolio", "Start a business", "Learning", "Other"]
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "What are your primary goals?") {
                surveyVM.previousStep()
            }
            
            MultiChoiceList(choices: choices, selections: $surveyVM.answers.goals)
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

// 6: Human Advisor
struct HumanAdvisorQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    let choices = ["No", "Yes"]
    let advisorProviders = [
        "Blackrock",
        "Vanguard",
        "Fidelity",
        "Schwab",
        "Morgan Stanley",
        "JP Morgan",
        "Goldman Sachs",
        "Charles Schwab",
        "Edward Jones",
        "Raymond James",
        "Ameriprise",
        "TIAA",
        "Merrill Lynch",
        "Wells Fargo Advisors",
        "UBS",
        "Other"
    ]
    
    @State private var showAdvisorPicker = false  // Local state for animation
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "Do you currently have a financial advisor?") {
                surveyVM.previousStep()
            }
            
            // Single choice list for Yes/No
            SingleChoiceList(choices: choices, selection: $surveyVM.answers.hasAdvisor)
                .onChange(of: surveyVM.answers.hasAdvisor) { newValue in
                    withAnimation(.easeInOut) {
                        showAdvisorPicker = (newValue == "Yes")
                    }
                }
            
            if showAdvisorPicker {
                VStack {
                    
                    // Advisor provider picker
                    Picker("Select Advisor Provider", selection: $surveyVM.answers.advisor) {
                        ForEach(advisorProviders, id: \.self) { provider in
                            Text(provider).tag(provider)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))  // Smooth transition
            }
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

// 7: Employment
struct EmploymentQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    let choices = [
        "Unemployed",
        "Corporate Employment",
        "Self-Employed",
        "Retired",
        "Prefer Not to Say"
    ]
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "What is your employment status?") {
                surveyVM.previousStep()
            }
            
            SingleChoiceList(choices: choices, selection: $surveyVM.answers.employment)
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

// 8: Industries Interested
struct IndustriesQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    let allIndustries = [
        "Tech",
        "Healthcare",
        "Finance",
        "Energy",
        "Consumer Goods",
        "Industrial",
        "Real Estate"
    ]
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "Which industries are you interested in?") {
                surveyVM.previousStep()
            }
            
            // Multiple selection
            MultiChoiceList(choices: allIndustries, selections: $surveyVM.answers.selectedIndustries)
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

// 9: Assets
struct AssetsQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    let choices = [
        "Real Estate",
        "Liquid Bank Accounts",
        "Brokerage/Equity Holdings",
        "Retirement Accounts (401k, IRA, etc.)",
        "Cryptocurrency",
        "Commodities (Gold, Silver, etc.)",
        "Private Business Ownership",
        "Collectibles (Art, Antiques, etc.)",
        "None of the above"
    ]
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "Where do you have assets?") {
                surveyVM.previousStep()
            }
            
            // Multiple selection
            MultiChoiceList(choices: choices, selections: $surveyVM.answers.ownedAssets)
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

// 10: File your own taxes?
// 10: File your own taxes?
struct FileTaxesQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    let choices = ["No", "Yes"]
    let taxFilingTools = [
        "TurboTax",
        "H&R Block",
        "TaxAct",
        "FreeTaxUSA",
        "IRS Free File",
        "Other"
    ]
    
    @State private var showTaxPicker = false  // Local state for animation
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "Do you file your own taxes?") {
                surveyVM.previousStep()
            }
            
            // Single choice list for Yes/No
            SingleChoiceList(choices: choices, selection: $surveyVM.answers.filesOwnTaxes)
                .onChange(of: surveyVM.answers.filesOwnTaxes) { newValue in
                    withAnimation(.easeInOut) {
                        showTaxPicker = (newValue == "Yes")
                    }
                }
            
            if showTaxPicker {
                VStack {
                    Text("Which tool do you use?")
                        .bold()
                        .font(.title)
                        .padding(.top, 16)
                    
                    // Tax filing tools picker
                    Picker("Tax Filing Tools", selection: $surveyVM.answers.taxTool) {
                        ForEach(taxFilingTools, id: \.self) { tool in
                            Text(tool).tag(tool)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))  // Smooth transition
            }
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

// 11: Credit Score
struct CreditScoreQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "What is your credit score?") {
                surveyVM.previousStep()
            }
            
            Picker("Credit Score", selection: $surveyVM.answers.creditScore) {
                ForEach(Array(stride(from: 0, through: 900, by: 1)), id: \.self) { amount in
                    Text("\(amount)").tag(amount)
                }
            }
            .pickerStyle(WheelPickerStyle())
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

// 12: Debts
struct DebtQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    let choices = ["No", "Yes"]
    
    @State private var showDebtPicker = false  // Local state for animation
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "Do you have any debts?") {
                surveyVM.previousStep()
            }
            
            // Single choice list
            SingleChoiceList(choices: choices, selection: $surveyVM.answers.hasDebts)
                .onChange(of: surveyVM.answers.hasDebts) { newValue in
                    withAnimation(.easeInOut) {
                        showDebtPicker = (newValue == "Yes")
                    }
                }
            
            if showDebtPicker {
                VStack {
                    Text("How much total debt?")
                        .bold()
                        .font(.title)
                        .padding(.top, 16)
                    
                    // Debt amount picker
                    Picker("Debt Amount (in thousands)", selection: $surveyVM.answers.debtAmount) {
                        ForEach(Array(stride(from: 0, through: 1_000_000, by: 5_000)), id: \.self) { value in
                            Text("$\(value)").tag(value)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))  // Smooth transition
            }
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}
// 13: How much are you saving each month?
struct SavingMonthlyQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "How much do you save each month?") {
                surveyVM.previousStep()
            }
            
            // Convert the stride to an array for ForEach
            Picker("Monthly Savings (in thousands)", selection: $surveyVM.answers.savingMonthly) {
                ForEach(Array(stride(from: 0, through: 1_000_000, by: 1_000)), id: \.self) { amount in
                    Text("$\(amount)").tag(amount)
                }
            }
            .pickerStyle(WheelPickerStyle())
            
            SurveyNavigationFooter(nextDisabled: false) {
                // On next, let's go to final page
                surveyVM.determineFinancialStatus()
                surveyVM.nextStep()
            }
        }
    }
}

// 14: Final Page
struct FinalStatusView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    @State private var progressValue: Double = 0
    @State private var showFinalMessage: Bool = false
    
    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .cornerRadius(120)
                .padding()
            
            Text("Creating Your Custom Financial Plan")
                .bold()
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding(.bottom, 30)
            
            // Loading bar
            ProgressView(value: progressValue, total: 100)
                .progressViewStyle(LinearProgressViewStyle())
                .accentColor(.primary)
                .frame(width: 250)
                .padding(.bottom, 20)
            
            // Final message once loading completes
            if showFinalMessage {
                Text("Your Custom Financial Plan Is Ready. Are You Ready To Start Your Financial Journey?")
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Spacer()
        }
        .onChange(of: progressValue) { newValue in
            // Once progress hits 100, show the final message
            if newValue >= 100 {
                withAnimation(.spring) {
                    showFinalMessage = true
                }
            }
        }
        .onAppear {
            // Start a timer to increment progressValue every second
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                
                    if progressValue < 100 {
                        withAnimation(.spring) {
                            progressValue += 30 // Increment progress by 10 each second
                        }
                    } else {
                        timer.invalidate() // Stop the timer when progress reaches 100
                    }
            }
        }
    }
}
// MARK: - Preview

struct SurveyView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyView()
    }
}
