import SwiftUI

struct ExpenseRow: View {
    var expense: Expense
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.purpose ?? "")
                    .font(.headline)
                Text(expense.date ?? Date(), formatter: itemFormatter)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(expense.location ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("\(expense.amount, specifier: "%.2f")")
                    .font(.headline)
            }
        }
        .padding(.vertical, 8)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

struct ExpenseRow_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let newExpense = Expense.example
        
        return ExpenseRow(expense: newExpense)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
