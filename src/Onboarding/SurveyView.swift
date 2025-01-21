import SwiftUI

// MARK: - Model

/// Holds all the user's answers from the survey
struct SurveyAnswers: Codable {
    var age: Int = 18
    var salary: Int = 50_000
    var creditScore: Int = 700
    var debtAmount: Int = 0
    var savingMonthly: Int = 0
    
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

/// Persists SurveyAnswers to local storage
struct SurveyPersistenceManager {
    static private let kUserDefaultsKey = "PuulUserSurveyAnswers"
    
    static func saveAnswers(_ answers: SurveyAnswers) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(answers) {
            UserDefaults.standard.set(data, forKey: kUserDefaultsKey)
        }
    }
    
    static func loadAnswers() -> SurveyAnswers? {
        guard let data = UserDefaults.standard.data(forKey: kUserDefaultsKey) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(SurveyAnswers.self, from: data)
    }
    
    static func clearAnswers() {
        // If you ever need to clear the stored answers
        UserDefaults.standard.removeObject(forKey: kUserDefaultsKey)
    }
}

// MARK: - ViewModel

class SurveyViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var answers = SurveyAnswers()
    
    // We'll use 0...13 for questions, and 14 for final
    let totalSteps = 14
    
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

struct SurveyContainerView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    @EnvironmentObject var storeVM: StoreVM
    @State private var done: Bool = false
    @State var showingAlert = false
    @Environment(\.dismiss) private var dismiss
    
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
                    // This is the skip button
                    showingAlert = true
                } label: {
                    HStack {
                        Text("Skip")
                        Image(systemName: "chevron.right.2")
                    }
                    .font(.title3)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                }
                .buttonStyle(HapticButtonStyle())
            }
            .opacity(surveyVM.currentStep == 0 ? 0 : 1)
            
            // MARK: - Paging TabView for Survey Steps
            TabView(selection: $surveyVM.currentStep) {
                IntroductionView()
                    .tag(0)
                AgeQuestionView()
                    .tag(1)
                LocationQuestionView()
                    .tag(2)
                EmploymentQuestionView()
                    .tag(3)
                SalaryQuestionView()
                    .tag(4)
                GoalQuestionView()
                    .tag(5)
                HumanAdvisorQuestionView()
                    .tag(6)
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
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .animation(.spring(), value: surveyVM.currentStep)
            
            Spacer()
            
            // MARK: - Next Button
            Button(action: {
                if surveyVM.currentStep < surveyVM.totalSteps {
                    // If about to go from step 13 to 14, call logic for final status
                    if surveyVM.currentStep == 13 {
                        surveyVM.determineFinancialStatus()
                    }
                    surveyVM.nextStep()
                } else {
                    // If we are on the final step, user clicked "Let's Plan for the Future"
                    withAnimation(.easeInOut) {
                        done = true
                        // -- CHANGE HERE: save the final answers to local storage
                        SurveyPersistenceManager.saveAnswers(surveyVM.answers)
                        dismiss()
                    }
                }
            }) {
                Text(surveyVM.currentStep == surveyVM.totalSteps
                     ? "Let's Plan for the Future"
                     : "Next")
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
        .background {
            Color.primary.colorInvert()
                .ignoresSafeArea()
        }
        .offset(x: done ? -deviceWidth : 0)
        .environmentObject(StoreVM())
//        .onAppear {
//            if storeVM.hasUnlockedPro {
//                done = true
//            } else {
//                done = false
//            }
//        }
//        .onChange(of: storeVM.hasUnlockedPro) { hasUnlockedPro in
//            if hasUnlockedPro {
//                done = true
//            } else {
//                done = false
//            }
//        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Are you sure?"),
                message: Text("This information helps Puul provide you with better services. All data is stored on your device, protecting your privacy."),
                primaryButton: .destructive(Text("Skip"), action: {
                    // If user hits skip, do NOT save. We'll dismiss without storing.
                    withAnimation(.easeInOut) {
                        done = true
                        dismiss()
                    }
                }),
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
    }
}

// MARK: - Common Survey Navigation

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
                        Image(systemName: "checkmark.circle.fill")
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selections.contains(choice) {
                        selections.removeAll(where: { $0 == choice })
                    } else {
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

struct AgeQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "What's your Age?") {
                surveyVM.previousStep()
            }
            
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

struct SalaryQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "What's your Salary?") {
                surveyVM.previousStep()
            }
            
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
    
    @State private var showAdvisorPicker = false
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "Do you currently have a financial advisor?") {
                surveyVM.previousStep()
            }
            
            SingleChoiceList(choices: choices, selection: $surveyVM.answers.hasAdvisor)
                .onChange(of: surveyVM.answers.hasAdvisor) { newValue in
                    withAnimation(.easeInOut) {
                        showAdvisorPicker = (newValue == "Yes")
                    }
                }
            
            if showAdvisorPicker {
                VStack {
                    Picker("Select Advisor Provider", selection: $surveyVM.answers.advisor) {
                        ForEach(advisorProviders, id: \.self) { provider in
                            Text(provider).tag(provider)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

struct EmploymentQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    let choices = [
        "Unemployed",
        "Employed Full-Time (W-2)",
        "Employed Part-Time (1099)",
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
            
            MultiChoiceList(choices: allIndustries, selections: $surveyVM.answers.selectedIndustries)
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

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
            
            MultiChoiceList(choices: choices, selections: $surveyVM.answers.ownedAssets)
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

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
    
    @State private var showTaxPicker = false
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "Do you file your own taxes?") {
                surveyVM.previousStep()
            }
            
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
                    
                    Picker("Tax Filing Tools", selection: $surveyVM.answers.taxTool) {
                        ForEach(taxFilingTools, id: \.self) { tool in
                            Text(tool).tag(tool)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

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

struct DebtQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    let choices = ["No", "Yes"]
    
    @State private var showDebtPicker = false
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "Do you have any debts?") {
                surveyVM.previousStep()
            }
            
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
                    
                    Picker("Debt Amount (in thousands)", selection: $surveyVM.answers.debtAmount) {
                        ForEach(Array(stride(from: 0, through: 1_000_000, by: 5_000)), id: \.self) { value in
                            Text("$\(value)").tag(value)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

struct SavingMonthlyQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "How much do you save each month?") {
                surveyVM.previousStep()
            }
            
            Picker("Monthly Savings (in thousands)", selection: $surveyVM.answers.savingMonthly) {
                ForEach(Array(stride(from: 0, through: 1_000_000, by: 1_000)), id: \.self) { amount in
                    Text("$\(amount)").tag(amount)
                }
            }
            .pickerStyle(WheelPickerStyle())
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.determineFinancialStatus()
                surveyVM.nextStep()
            }
        }
    }
}

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
            
            ProgressView(value: progressValue, total: 100)
                .progressViewStyle(LinearProgressViewStyle())
                .accentColor(.primary)
                .frame(width: 250)
                .padding(.bottom, 20)
            
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
            if newValue >= 100 {
                withAnimation(.spring) {
                    showFinalMessage = true
                }
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if progressValue < 100 {
                    withAnimation(.spring) {
                        progressValue += 30
                    }
                } else {
                    timer.invalidate()
                }
            }
        }
    }
}
// MARK: - Preview

struct SurveyView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyView()
            .environmentObject(StoreVM())
    }
}
