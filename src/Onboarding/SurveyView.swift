import SwiftUI
import Charts
// MARK: - Model

/// Holds all the user's answers from the survey
struct SurveyAnswers: Codable {
    var age: Int = 18
    var salary: Int = 50_000
    var creditScore: Int = 700
    var debtAmount: Int = 0
    var savingMonthly: Int = 0
    
    var location: String = "United States"
    var riskTolerance: String = "Medium"
    var goals: [String] = []
    var hasAdvisor: String = "No"
    var advisor: String = "None"
    var employment: String = "Unemployed"
    var selectedIndustries: [String] = []
    var ownedAssets: [String] = []
    var totalNetWorth: Int = 0
    var filesOwnTaxes: String = "No"
    var taxTool: String = "None"
    var hasDebts: String = "No"
    
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
        
//        if monthlySaving >= 10_000 && totalDebt <= 1_000 {
//            answers.financialStatus = "Financially Free"
//        } else if monthlySaving >= 5_000 && totalDebt < 20_000 {
//            answers.financialStatus = "Stable"
//        } else if monthlySaving >= 2_000 && totalDebt < 50_000 {
//            answers.financialStatus = "Independent"
//        } else {
//            answers.financialStatus = "Dependent"
//        }
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
    @State var showStats = false
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.label
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray4
    }
    
    var body: some View {
        VStack {
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
                }
                .buttonStyle(HapticButtonStyle())
                ProgressView(value: Double(surveyVM.currentStep), total: 14)
                    .progressViewStyle(LinearProgressViewStyle())
                    .accentColor(.primary)
                    .padding(.horizontal)
                    .animation(.linear(duration: 1), value: surveyVM.currentStep)
            }
            .opacity(surveyVM.currentStep == 0 ? 0 : 1)
            
            // MARK: - Paging TabView for Survey Steps
            TabView(selection: $surveyVM.currentStep) {
//                ScrollView {
                    IntroductionView()
//                }
                    .tag(0)
//                ScrollView {
                    AgeQuestionView()
//                }
                    .tag(1)
//                ScrollView {
                    LocationQuestionView()
//                }
                    .tag(2)
//                ScrollView {
                    EmploymentQuestionView()
//                }
                    .tag(3)
//                ScrollView {
                    SalaryQuestionView()
//                }
                    .tag(4)
                ScrollView {
                    GoalQuestionView()
                }
                .padding(.bottom, 45)
                    .tag(5)
//                ScrollView {
                    HumanAdvisorQuestionView()
//                }
//                .defaultScrollAnchor(.bottom)
                    .tag(6)
//                ScrollView {
                    RiskToleranceQuestionView()
//                }
                    .tag(7)
                ScrollView {
                    IndustriesQuestionView()
                }
                .padding(.bottom, 45)
                    .tag(8)
//                ScrollView {
                    AssetsQuestionView()
//                }
                .padding(.bottom, 45)
                    .tag(9)
//                ScrollView {
                    FileTaxesQuestionView()
//                }
//                .defaultScrollAnchor(.bottom)
                    .tag(10)
//                ScrollView {
                    CreditScoreQuestionView()
//                }
                    .tag(11)
//                ScrollView {
                    DebtQuestionView()
//                }
                    .tag(12)
//                ScrollView {
                    SavingMonthlyQuestionView()
//                }
                    .tag(13)
//                ScrollView {
                    FinalStatusView()
//                }
                    .tag(14)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .animation(.spring(), value: surveyVM.currentStep)
            
//            Spacer()
            
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
                        dismiss()
                    }
                    SurveyPersistenceManager.saveAnswers(surveyVM.answers)
                    showStats = true
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
//        .onChange(of: done) { _ in
//            showStats = true
//        }
        .sheet(isPresented: $showStats) {
            RatingsView()
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
                    .minimumScaleFactor(0.5)
                    .padding()
            }
//            .frame(maxHeight: .infinity)
            .padding([.horizontal])
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
        .padding(.bottom, 45)
    }
}

struct SegmentedSingleChoiceList: View {
    let choices: [String]
    @Binding var selection: String
    
    var body: some View {
        Picker("", selection: $selection) {
            ForEach(choices, id: \.self) { choice in
                Text(choice).tag(choice)
            }
        }
        .pickerStyle(.segmented)
        .frame(width: 300)
    }
}

struct MultiChoiceList: View {
    let choices: [String]
    @Binding var selections: [String]
    @StateObject public var model: AppModel = AppModel()
    var body: some View {
        VStack {
            Text("Multiple Selection")
                .font(.headline)
            ForEach(choices, id: \.self) { choice in
                HStack {
                    if selections.contains(choice) {
                        Image(systemName: "checkmark.circle.fill")
                    }
                    Text(choice)
                    Spacer()
                }
                .animation(.default, value: selections)
                .contentShape(Rectangle())
                .padding()
                .onTapGesture {
                    if model.hapticModeOn {
                        impactMedium.impactOccurred()
                    }
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
        .padding(.bottom, 45)
    }
}

struct AssetData: Identifiable, Hashable {
    var category: String
    var amount: Double
    var id = UUID()
}

struct AssetsQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    // All possible asset choices.
    let assetData: [AssetData] = [
        AssetData(category: "Real Estate", amount: 500_000),
        AssetData(category: "Liquid Bank Accounts", amount: 60_000),
        AssetData(category: "Brokerage/Equity Holdings", amount: 100_000),
        AssetData(category: "Retirement Accounts (401k, IRA, etc.)", amount: 60_000),
        AssetData(category: "Cryptocurrency", amount: 30_000),
        AssetData(category: "Commodities (Gold, Silver, etc.)", amount: 15_000),
        AssetData(category: "Private Business Ownership", amount: 35_000),
        AssetData(category: "Collectibles (Art, Antiques, etc.)", amount: 20_000),
        AssetData(category: "None of the above", amount: 1_000)
    ]
    
    // Assets user has selected; updated amounts stored here.
    @State private var selectedAssetData: [AssetData] = []
    
    // Raw text inputs keyed by category (so we keep user-entered formatting while typing).
    @State private var inputAmounts: [String: String] = [:]
    
    // Track which TextField is focused. We’ll use this to auto-scroll into view.
    @FocusState private var focusedField: String?
    
    // A helper formatter for currency-like fields (no decimals).
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    @StateObject public var model: AppModel = AppModel()

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack {
                    
                    // Top illustration
                    Image(systemName: "chart.pie")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .padding(.top, 45)
                    
                    // Header with back navigation
                    SurveyNavigationHeader(title: "Where do you have assets?") {
                        surveyVM.previousStep()
                    }
                    
                    // Show chart + total net worth if we have selected any assets
                    if !selectedAssetData.isEmpty {
                        VStack {
                            GroupBox("Total Net Worth: $\(Int(selectedAssetData.map(\.amount).reduce(0, +)))") {
                                Chart(selectedAssetData) { asset in
                                    BarMark(
                                        x: .value("Amount", asset.amount),
                                        stacking: .normalized
                                    )
                                    .foregroundStyle(by: .value("Category", asset.category))
                                }
                                .frame(height: dynamicChartHeight)
                                .animation(.default, value: selectedAssetData)
                            }
                            .padding()
                        }
                    }
                    
                    Text("Multiple Selection")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    // List out all asset categories
                    ForEach(assetData, id: \.category) { asset in
                        let isSelected = selectedAssetData.contains { $0.category == asset.category }
                        
                        VStack {
                            HStack {
                                // Tap to select/deselect
                                HStack {
                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                    Text(asset.category)
                                    Spacer()
                                }
                                .contentShape(Rectangle()) // Makes entire row tappable
                                .onTapGesture {
                                    if model.hapticModeOn {
                                        impactMedium.impactOccurred()
                                    }
                                    
                                    if isSelected {
                                        // Deselect
                                        selectedAssetData.removeAll { $0.category == asset.category }
                                        surveyVM.answers.ownedAssets.removeAll { $0 == asset.category }
                                        inputAmounts[asset.category] = nil
                                    } else {
                                        // Select
                                        selectedAssetData.append(asset)
                                        surveyVM.answers.ownedAssets.append(asset.category)
                                        // Pre-fill text field with the default amount
                                        inputAmounts[asset.category] = "\(Int(asset.amount))"
                                        // Focus newly-added asset's text field
                                        focusedField = asset.category
                                    }
                                    // Recalc total whenever selection changes
                                    recalcTotalNetWorth()
                                }
                                
                                // If selected, show a text field to update its amount
                                if isSelected,
                                   let index = selectedAssetData.firstIndex(where: { $0.category == asset.category }) {
                                    
                                    TextField(
                                        "Amount",
                                        text: Binding<String>(
                                            get: {
                                                // If user is actively editing this field, show raw typed text
                                                if focusedField == asset.category {
                                                    return inputAmounts[asset.category] ?? ""
                                                } else {
                                                    // Not focused -> show formatted amount
                                                    let amount = selectedAssetData[index].amount
                                                    return currencyFormatter.string(from: NSNumber(value: amount)) ?? ""
                                                }
                                            },
                                            set: { newValue in
                                                // Always store raw typed text
                                                inputAmounts[asset.category] = newValue
                                                // Sanitize to digits only
                                                let sanitized = newValue.filter(\.isNumber)
                                                if let value = Double(sanitized) {
                                                    selectedAssetData[index].amount = value
                                                } else {
                                                    selectedAssetData[index].amount = 0
                                                }
                                                recalcTotalNetWorth()
                                            }
                                        )
                                    )
                                    .keyboardType(.numberPad)
                                    .frame(width: 100)
                                    .multilineTextAlignment(.trailing)
                                    .focused($focusedField, equals: asset.category)
                                    // Whenever focus changes, we can auto-scroll
                                    .onChange(of: focusedField) { newFocused in
                                        if newFocused == asset.category {
                                            withAnimation {
                                                scrollProxy.scrollTo(asset.category, anchor: .center)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            
                            Divider()
                                .background(Color.gray)
                                .padding(.leading)
                        }
                        .id(asset.category) // For scrolling
                    }
                    
                    Spacer().frame(height: 45) // Extra bottom padding
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    if focusedField != nil {
                        Button("Done") {
                            // Dismiss keyboard by clearing the focused field
                            focusedField = nil
                        }
                    }
                }
            }
        }
    }
    
    /// Dynamically adjust chart height.
    private var dynamicChartHeight: CGFloat {
        let minHeight: CGFloat = 60
        let additionalHeightPerAsset: CGFloat = 30
        return selectedAssetData.count > 1
            ? minHeight + CGFloat(selectedAssetData.count - 1) * additionalHeightPerAsset
            : minHeight
    }
    
    /// Recompute and store the total net worth in the shared view model.
    private func recalcTotalNetWorth() {
        let total = selectedAssetData.reduce(0) { $0 + $1.amount }
        surveyVM.answers.totalNetWorth = Int(total)
    }
}

//#if canImport(UIKit)
//extension View {
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
//                                        to: nil, from: nil, for: nil)
//    }
//}
//#endif


// MARK: - QUESTION VIEWS

struct IntroductionView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "doc.text")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 0, maxWidth: 150, minHeight: 0, maxHeight: 150)
                .padding()
            Text("Client Questionnaire")
                .font(.largeTitle)
                .bold()
                .padding()
            
            Text("The following questions help Puul create your financial plan based on your needs and goals.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding()
            HStack {
                Image(systemName: "clock")
                Text("Takes 1 minute")
            }
            .bold()
            .padding()
            Spacer()
            Spacer()
        }
    }
}

struct AgeQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 0, maxWidth: 150, minHeight: 0, maxHeight: 150)
                .padding(.top, 45)
            SurveyNavigationHeader(title: "What's your Age?") {
                surveyVM.previousStep()
            }
            
            Picker("Select Age", selection: $surveyVM.answers.age) {
                ForEach(4..<101, id: \.self) { age in
                    Text("\(age)").tag(age)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .padding(.bottom, 45)
        }
    }
}

struct SalaryQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "dollarsign.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 0, maxWidth: 150, minHeight: 0, maxHeight: 150)
                .padding(.top, 45)
            SurveyNavigationHeader(title: "What's your salary?") {
                surveyVM.previousStep()
            }
            
            Picker("Select Salary (in thousands)", selection: $surveyVM.answers.salary) {
                ForEach(Array(stride(from: 0, through: 2_000_000, by: 5_000)), id: \.self) { salaryValue in
                    Text("$\(salaryValue)").tag(salaryValue)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .padding(.bottom, 45)
            
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
            Image(systemName: "mappin.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 0, maxWidth: 150, minHeight: 0, maxHeight: 150)
                .padding(.top, 45)
            SurveyNavigationHeader(title: "Your Location:") {
                surveyVM.previousStep()
            }
            
            SingleChoiceList(choices: choices, selection: $surveyVM.answers.location)
            
        }
    }
}

struct RiskToleranceQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    let choices = ["Super risk averse", "Low", "Medium", "High", "Super high risk"]
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 0, maxWidth: 150, minHeight: 0, maxHeight: 150)
                .padding(.top, 45)
            SurveyNavigationHeader(title: "Risk Tolerance") {
                surveyVM.previousStep()
            }
            
            SingleChoiceList(choices: choices, selection: $surveyVM.answers.riskTolerance)
            
        }
    }
}

struct GoalQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    let choices = ["Buy a home", "Retire", "Grow investment portfolio", "Start a business", "Learning", "Other"]
    
    var body: some View {
        VStack {
            Image(systemName: "target")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 0, maxWidth: 150, minHeight: 0, maxHeight: 150)
                .padding(.top, 45)
            SurveyNavigationHeader(title: "What are your primary goals?") {
                surveyVM.previousStep()
            }
            
            MultiChoiceList(choices: choices, selections: $surveyVM.answers.goals)
            
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
            Image(systemName: "person.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 0, maxWidth: 150, minHeight: 0, maxHeight: 150)
                .padding(.top, 45)
            SurveyNavigationHeader(title: "Do you have a financial advisor?") {
                surveyVM.previousStep()
            }
            
            SegmentedSingleChoiceList(choices: choices, selection: $surveyVM.answers.hasAdvisor)
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
                    .frame(minHeight: 200)
                    .pickerStyle(WheelPickerStyle())
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
//            Spacer()
            
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
            Image(systemName: "bag")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 0, maxWidth: 150, minHeight: 0, maxHeight: 150)
                .padding(.top, 45)
            SurveyNavigationHeader(title: "Employment status:") {
                surveyVM.previousStep()
            }
            
            SingleChoiceList(choices: choices, selection: $surveyVM.answers.employment)
            
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
            Image(systemName: "building.2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 0, maxWidth: 150, minHeight: 0, maxHeight: 150)
                .padding(.top, 45)
            SurveyNavigationHeader(title: "Which industries are you interested in?") {
                surveyVM.previousStep()
            }
            
            MultiChoiceList(choices: allIndustries, selections: $surveyVM.answers.selectedIndustries)
            
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
            Image(systemName: "building.columns")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 0, maxWidth: 150, minHeight: 0, maxHeight: 150)
                .padding(.top, 45)
            SurveyNavigationHeader(title: "Do you file your own taxes?") {
                surveyVM.previousStep()
            }
            
            SegmentedSingleChoiceList(choices: choices, selection: $surveyVM.answers.filesOwnTaxes)
                .onChange(of: surveyVM.answers.filesOwnTaxes) { newValue in
                    withAnimation(.easeInOut) {
                        showTaxPicker = (newValue == "Yes")
                    }
                }
            
            if showTaxPicker {
                VStack {
                    Text("Which tool do you use?")
                        .bold()
//                        .font(.title3)
                        .padding(.top, 16)
                    
                    Picker("Tax Filing Tools", selection: $surveyVM.answers.taxTool) {
                        ForEach(taxFilingTools, id: \.self) { tool in
                            Text(tool).tag(tool)
                        }
                    }
                    .frame(minHeight: 200)
                    .pickerStyle(WheelPickerStyle())
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

        }
    }
}

struct CreditScoreQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "creditcard")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 0, maxWidth: 150, minHeight: 0, maxHeight: 150)
                .padding(.top, 45)
            SurveyNavigationHeader(title: "What is your credit score?") {
                surveyVM.previousStep()
            }
            
            Picker("Credit Score", selection: $surveyVM.answers.creditScore) {
                ForEach(Array(stride(from: 0, through: 900, by: 1)), id: \.self) { amount in
                    Text("\(amount)").tag(amount)
                }
            }
            .frame(minHeight: 200)
            .pickerStyle(WheelPickerStyle())
            .padding(.bottom, 45)

        }
    }
}

struct DebtQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    let choices = ["No", "Yes"]
    
    @State private var showDebtPicker = false
    
    var body: some View {
        VStack {
            Image(systemName: "paperclip")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 0, maxWidth: 150, minHeight: 0, maxHeight: 150)
                .padding(.top, 45)
            SurveyNavigationHeader(title: "Do you have any debts?") {
                surveyVM.previousStep()
            }
            
            SegmentedSingleChoiceList(choices: choices, selection: $surveyVM.answers.hasDebts)
                .onChange(of: surveyVM.answers.hasDebts) { newValue in
                    withAnimation(.easeInOut) {
                        showDebtPicker = (newValue == "Yes")
                    }
                }
            
            if showDebtPicker {
                VStack {
                    Text("How much total debt?")
                        .bold()
                        .font(.title3)
                        .padding(.top)
                    
                    Picker("Debt Amount (in thousands)", selection: $surveyVM.answers.debtAmount) {
                        ForEach(Array(stride(from: 0, through: 1_000_000, by: 5_000)), id: \.self) { value in
                            Text("$\(value)").tag(value)
                        }
                    }
                    .frame(minHeight: 200)
                    .pickerStyle(WheelPickerStyle())
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, 45)
            }
            
        }
    }
}

struct SavingMonthlyQuestionView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "banknote")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 0, maxWidth: 150, minHeight: 0, maxHeight: 150)
                .padding(.top, 45)
            SurveyNavigationHeader(title: "How much do you save each month?") {
                surveyVM.previousStep()
            }
            
            Picker("Monthly Savings (in thousands)", selection: $surveyVM.answers.savingMonthly) {
                ForEach(Array(stride(from: 0, through: 1_000_000, by: 1_000)), id: \.self) { amount in
                    Text("$\(amount)").tag(amount)
                }
            }
            .frame(minHeight: 200)
            .pickerStyle(WheelPickerStyle())
            .padding(.bottom, 45)
        }
    }
}

struct FinalStatusView: View {
    @EnvironmentObject var surveyVM: SurveyViewModel
    @State private var progressValue: Double = 0
    @State private var showFinalMessage: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "list.clipboard")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 0, maxWidth: 150, minHeight: 0, maxHeight: 150)
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
                Text("Your custom financial plan is ready. Get ready to start your financial journey!")
                    .font(.title3)
//                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
            }
            Spacer()
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
