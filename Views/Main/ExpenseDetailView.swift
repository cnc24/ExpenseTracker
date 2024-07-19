import SwiftUI
import UIKit
import CoreData

struct ExpenseDetailView: View {
    @ObservedObject var expense: Expense
    @ObservedObject var userViewModel: UserViewModel
    @State private var showingEditView = false
    @State private var showingImageFullScreen = false
    
    var onSave: (() -> Void)?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                GeometryReader { geometry in
                    if let imageData = expense.image, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: geometry.size.height)
                            .cornerRadius(10)
                            .clipped()
                            .onTapGesture {
                                showingImageFullScreen.toggle()
                            }
                            .fullScreenCover(isPresented: $showingImageFullScreen) {
                                FullScreenImageView(image: uiImage)
                            }
                    }
                }
                .frame(height: 300)
                
                Group {
                    detailRow(label: NSLocalizedString("Date:", comment: "Label for the date of the expense"), value: formattedDate(expense.date))
                    detailRow(label: NSLocalizedString("Purpose:", comment: "Label for the purpose of the expense"), value: expense.purpose ?? NSLocalizedString("No purpose", comment: "Default text for missing purpose"))
                    detailRow(label: NSLocalizedString("Amount:", comment: "Label for the amount of the expense"), value: formattedAmount(expense.amount))
                    detailRow(label: NSLocalizedString("Location:", comment: "Label for the location of the expense"), value: expense.location ?? NSLocalizedString("No location", comment: "Default text for missing location"))
                }
                
                Group {
                    sectionRow(label: NSLocalizedString("Notes:", comment: "Label for the notes of the expense"), value: expense.notes ?? NSLocalizedString("No notes", comment: "Default text for missing notes"))
                    sectionRow(label: NSLocalizedString("Category:", comment: "Label for the category of the expense"), value: formattedCategories(expense.categories as? Set<Category>))
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitle(NSLocalizedString("Expense Details", comment: "Title for the expense detail view"), displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            showingEditView.toggle()
        }) {
            Image(systemName: "pencil")
        })
        .sheet(isPresented: $showingEditView) {
            AddExpenseView(viewModel: ExpenseViewModel(viewContext: expense.managedObjectContext!), userViewModel: userViewModel, expenseToEdit: expense)
                .onDisappear {
                    onSave?()
                }
        }
    }
    
    @ViewBuilder
    private func detailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.trailing) // Make sure the text aligns properly
            }
            Divider()
        }
    }
    
    @ViewBuilder
    private func sectionRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
        Divider()
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return NSLocalizedString("No date", comment: "Default text for missing date") }
        return itemFormatter.string(from: date)
    }
    
    private func formattedAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    private func formattedCategories(_ categories: Set<Category>?) -> String {
        guard let categories = categories else { return NSLocalizedString("No category", comment: "Default text for missing category") }
        return categories.compactMap { $0.name }.joined(separator: ", ")
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

struct ExpenseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let newExpense = Expense.example
        
        return NavigationView {
            ExpenseDetailView(expense: newExpense, userViewModel: UserViewModel())
                .environment(\.managedObjectContext, context)
        }
    }
}
