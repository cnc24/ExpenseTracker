import SwiftUI

struct ExpenseDetailView: View {
    var expense: Expense
    var onEdit: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let imageData = expense.image, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .clipped()
                }
                
                Text("Purpose: \(expense.purpose ?? "No Purpose")")
                Text("Amount: \(expense.amount, specifier: "%.2f") €")
                Text("Location: \(expense.location ?? "No Location")")
                Text("Notes: \(expense.notes ?? "No Notes")")
                Text("Date: \(formattedDate(expense.date))")
                
                if let categories = expense.categories as? Set<Category> {
                    Text("Categories: \(formattedCategories(categories))")
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Expense Details")
        .navigationBarItems(trailing: Button(action: {
            onEdit()
        }) {
            Image(systemName: "pencil")
        })
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "No Date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    private func formattedCategories(_ categories: Set<Category>) -> String {
        categories.map { $0.name ?? "" }.joined(separator: ", ")
    }
}

struct ExpenseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseDetailView(expense: Expense.example, onEdit: {})
    }
}
