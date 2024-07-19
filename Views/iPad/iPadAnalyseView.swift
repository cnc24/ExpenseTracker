import SwiftUI
import Charts

struct iPadAnalyseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Expense.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: true)]
    ) private var expenses: FetchedResults<Expense>
    
    @State private var selectedAnalysisType: AnalysisType = .month
    
    enum AnalysisType: String, CaseIterable, Identifiable {
        case month = "Month"
        case category = "Category"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        VStack {
            
            Picker("Analysis Type", selection: $selectedAnalysisType) {
                ForEach(AnalysisType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedAnalysisType == .month {
                monthAnalysisView
            } else {
                Text(NSLocalizedString("No Expenses", comment: "Label for no expenses"))
                    .foregroundColor(.secondary)
                    .padding()
            }
            
            Spacer()
        }
        .navigationBarTitle("Analyse", displayMode: .inline)
    }
    
    private var monthAnalysisView: some View {
        VStack {
            if let monthData = calculateMonthData() {
                Chart {
                    ForEach(monthData, id: \.month) { data in
                        BarMark(
                            x: .value("Month", data.month),
                            y: .value("Amount", data.amount)
                        )
                        .annotation(position: .top) {
                            Text("\(data.amount, specifier: "%.2f") €")
                                .font(.caption)
                        }
                    }
                }
                .frame(height: 400)
                .padding()
                
                List {
                    ForEach(monthData, id: \.month) { data in
                        HStack {
                            Text(data.month)
                                .font(.headline)
                            Spacer()
                            Text(String(format: "%.2f €", data.amount))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } else {
                Text(NSLocalizedString("No Expenses", comment: "Label for no expenses"))
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
    
    private func calculateMonthData() -> [(month: String, amount: Double)]? {
        guard !expenses.isEmpty else { return nil }
        
        var monthData: [String: Double] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        for expense in expenses {
            if let date = expense.date {
                let month = dateFormatter.string(from: date)
                monthData[month, default: 0.0] += expense.amount
            }
        }
        
        let sortedMonthData = monthData.map { (month: $0.key, amount: $0.value) }
                    .sorted(by: { dateFormatter.date(from: $0.month)! < dateFormatter.date(from: $1.month)! })
                
        return sortedMonthData
    }
    
    private func calculateCategoryData() -> [(category: String, amount: Double)]? {
        guard !expenses.isEmpty else { return nil }
        
        var categoryData: [String: Double] = [:]
        
        for expense in expenses {
            if let categories = expense.categories as? Set<Category> {
                for category in categories {
                    if let categoryName = category.name {
                        categoryData[categoryName, default: 0.0] += expense.amount
                    }
                }
            }
        }
        
        return categoryData.map { (category: $0.key, amount: $0.value) }
            .sorted(by: { $0.category < $1.category })
    }
    
    
}


struct iPadAnalyseView_Previews: PreviewProvider {
    static var previews: some View {
        iPadAnalyseView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
