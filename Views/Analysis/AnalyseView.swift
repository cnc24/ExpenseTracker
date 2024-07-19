import SwiftUI
import Charts

struct AnalyseView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
          entity: Expense.entity(),
          sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: true)]
    ) private var expenses: FetchedResults<Expense>
    
    var body: some View {
        NavigationView {
            VStack {
                   
                if let categoryData = calculateCategoryData() {
                    Chart {
                        ForEach(categoryData, id: \.category) { data in
                            BarMark(
                                x: .value("Category", data.category),
                                y: .value("Amount", data.amount)
                            )
                            .annotation(position: .top) {
                                Text("\(data.amount, specifier: "%.2f") €")
                                    .font(.caption)
                            }
                        }
                    }
                    .frame(height: 300)
                    .padding()
                    
                    List {
                        ForEach(categoryData, id: \.category) { data in
                            HStack {
                                Text(data.category)
                                    .font(.headline)
                                Spacer()
                                Text(String(format: "%.2f €", data.amount))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } else {
                    Text(NSLocalizedString("No Expenses", comment: "label for no expenses"))
                        .foregroundColor(.secondary)
                        .padding()
                }
                
                Spacer()
            }
            .navigationBarTitle("Analyse", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
            })
        }
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

struct AnalyseView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyseView()
    }
}
