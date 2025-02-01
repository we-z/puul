import SwiftUI
import Charts

struct IncomeData: Identifiable, Equatable {
    var category: String
    var amount: Double
    var id = UUID()
}


let donationsIncomeData: [IncomeData] = [
    .init(category: "Legacies", amount: 84398),
    .init(category: "Other national campaigns and donations", amount: 84939),
    .init(category: "Daffodil Day", amount: 843984),
    .init(category: "Philanthropy and corporate partnerships", amount: 348938),
    .init(category: "Individual giving", amount: 4893)
]

struct BarAndPieChartView: View {
    var body: some View {
        VStack {
            GroupBox ( "Bar Chart - 2022 Donations and legacies (€ million)") {
                Chart(donationsIncomeData) {
                    BarMark(
                        x: .value("Amount", $0.amount),
                        stacking: .normalized
                    )
                    .foregroundStyle(by: .value("category", $0.category))
                }
                .frame(height: 100)
            }
            Spacer()
        }
        .padding()
    }
}


struct TempView: View {
    var body: some View {
        BarAndPieChartView()
    }
}


struct TempView_Previews: PreviewProvider {
    static var previews: some View {
        TempView()
    }
}
