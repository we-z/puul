import SwiftUI

// MARK: - Model

/// Holds all the user's answers from the survey
struct SurveyAnswers {
    // Example numeric inputs
    var age: Int = 18
    var salary: Int = 50_000
    var creditScoreRange: String = "600 - 650"
    var debtAmount: Int = 0
    var savingMonthly: Int = 0
    
    // Example multi-choice/single-choice
    var demographic: String = "Prefer not to say"
    var location: String = "United States"
    var riskTolerance: String = "Medium"
    var goal: String = "Buy a home"
    var hasHumanAdvisor: String = "No"
    var isEmployed: String = "Yes"
    var selectedIndustries: [String] = []
    var ownedAssets: [String] = []
    var filesOwnTaxes: String = "Yes"
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
            currentStep += 1
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    // Simple placeholder logic to determine a final "status"
    func determineFinancialStatus() {
        let saving = answers.savingMonthly
        let debt = answers.debtAmount
        
        if saving > 2000 && debt < 10000 {
            answers.financialStatus = "Free"
        } else if saving > 1000 && debt < 20000 {
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
    
    var body: some View {
        VStack {
            switch surveyVM.currentStep {
            case 0: AgeQuestionView()
            case 1: SalaryQuestionView()
            case 2: DemographicQuestionView()
            case 3: LocationQuestionView()
            case 4: RiskToleranceQuestionView()
            case 5: GoalQuestionView()
            case 6: HumanAdvisorQuestionView()
            case 7: EmploymentQuestionView()
            case 8: IndustriesQuestionView()
            case 9: AssetsQuestionView()
            case 10: FileTaxesQuestionView()
            case 11: CreditScoreQuestionView()
            case 12: DebtQuestionView()
            case 13: SavingMonthlyQuestionView()
            default: FinalStatusView()
            }
        }
//        .animation(.easeInOut, value: surveyVM.currentStep)
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
            HStack {
                Button(action: onBack) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.title3)
                    .foregroundColor(.primary)
                }
                .opacity(surveyVM.currentStep == 0 ? 0 : 1)
                Spacer()
            }
            Text(title)
                .bold()
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
        .padding()
    }
}

/// A common footer with a next button (bottom)
struct SurveyNavigationFooter: View {
    let nextDisabled: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            Button(action: onNext) {
                Text("Next")
                    .fontWeight(.semibold)
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.secondary.opacity(0.3))
                    .foregroundColor(.primary)
                    .cornerRadius(21)
            }
            .disabled(nextDisabled)
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
        List(choices, id: \.self) { choice in
            HStack {
                Text(choice)
                Spacer()
                if choice == selection {
                    Image(systemName: "checkmark")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selection = choice
            }
        }
        .frame(height: 600)
    }
}

/// A simple multi-selection list
struct MultiChoiceList: View {
    let choices: [String]
    @Binding var selections: [String]
    
    var body: some View {
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
    }
}

// MARK: - QUESTION VIEWS

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
                ForEach(18..<101, id: \.self) { age in
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
                ForEach(Array(stride(from: 0, through: 500_000, by: 5_000)), id: \.self) { salaryValue in
                    Text("$\(salaryValue)").tag(salaryValue)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 150)
            
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
        "Europe",
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
    
    let choices = ["Low", "Medium", "High"]
    
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
    
    let choices = ["Buy a home", "Retire", "Learning", "Other"]
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "What's your\nprimary goal?") {
                surveyVM.previousStep()
            }
            
            SingleChoiceList(choices: choices, selection: $surveyVM.answers.goal)
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

// 6: Human Advisor
struct HumanAdvisorQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    let choices = ["Yes", "No"]
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "Do you have a human financial advisor?") {
                surveyVM.previousStep()
            }
            
            SingleChoiceList(choices: choices, selection: $surveyVM.answers.hasHumanAdvisor)
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

// 7: Employment
struct EmploymentQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    let choices = ["Yes", "No"]
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "Are you currently employed?") {
                surveyVM.previousStep()
            }
            
            SingleChoiceList(choices: choices, selection: $surveyVM.answers.isEmployed)
            
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
struct FileTaxesQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    let choices = ["Yes", "No"]
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "Do you file your own taxes?") {
                surveyVM.previousStep()
            }
            
            SingleChoiceList(choices: choices, selection: $surveyVM.answers.filesOwnTaxes)
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

// 11: Credit Score
struct CreditScoreQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    let scoreRanges = [
        "< 600",
        "600 - 650",
        "650 - 700",
        "700 - 750",
        "750+"
    ]
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "What is your credit score range?") {
                surveyVM.previousStep()
            }
            
            SingleChoiceList(choices: scoreRanges, selection: $surveyVM.answers.creditScoreRange)
            
            SurveyNavigationFooter(nextDisabled: false) {
                surveyVM.nextStep()
            }
        }
    }
}

// 12: Debts
struct DebtQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    let choices = ["Yes", "No"]
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "Do you have any debts?") {
                surveyVM.previousStep()
            }
            
            SingleChoiceList(choices: choices, selection: $surveyVM.answers.hasDebts)
            
            // If "Yes", show a debt amount picker
            if surveyVM.answers.hasDebts == "Yes" {
                Text("How much total debt?")
                    .font(.subheadline)
                    .padding(.top, 16)
                
                // Convert the stride to an array for ForEach
                Picker("Debt Amount (in thousands)", selection: $surveyVM.answers.debtAmount) {
                    ForEach(Array(stride(from: 0, through: 1_000_000, by: 5_000)), id: \.self) { value in
                        Text("$\(value)").tag(value)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 150)
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
                ForEach(Array(stride(from: 0, through: 50_000, by: 1_000)), id: \.self) { amount in
                    Text("$\(amount)").tag(amount)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 150)
            
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
    
    var body: some View {
        VStack {
            SurveyNavigationHeader(title: "Summary") {
                surveyVM.previousStep()
            }
            
            Text("Based on your answers, you are financially \(surveyVM.answers.financialStatus).")
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            Button(action: {
                // Could navigate to a new feature or reset the survey
                print("Plan for the future tapped.")
            }) {
                Text("Let's Plan for the Future")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
    }
}

// MARK: - Preview

struct SurveyView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyView()
    }
}
