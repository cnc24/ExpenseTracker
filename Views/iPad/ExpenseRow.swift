import SwiftUI

struct ExpenseRow: View {
    var expense: Expense

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(itemFormatter.string(from: expense.date ?? Date()))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(expense.purpose ?? "No Purpose")
                    .font(.headline)
            }
            Spacer()
            Text("\(expense.amount, specifier: "%.2f") €")
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

struct ExpenseRow_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseRow(expense: Expense.example)
    }
}
