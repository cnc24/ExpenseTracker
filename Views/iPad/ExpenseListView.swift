import SwiftUI
import CoreData

struct ExpenseListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var viewModel: ExpenseViewModel
    @ObservedObject var userViewModel: UserViewModel

    @Binding var editingExpense: Expense?
    @Binding var showingAddExpenseView: Bool
    @Binding var showingAnalyseView: Bool
    @Binding var showingSettingsView: Bool
    @Binding var showingActionSheet: Bool
    @Binding var showingCameraView: Bool

    var body: some View {
        VStack {
            List {
                expenseRows
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Expenses", displayMode: .inline)
        }
        .overlay(
            addButton,
            alignment: .bottomTrailing
        )
        .sheet(isPresented: $showingAddExpenseView) {
            AddExpenseView(viewModel: viewModel, expenseToEdit: editingExpense, userViewModel: userViewModel)
                .environment(\.managedObjectContext, viewContext)
                .onDisappear {
                    viewModel.fetchExpenses()
                    editingExpense = nil
                }
        }
        .sheet(isPresented: $showingCameraView) {
            if userViewModel.isProUser {
                ImagePicker(sourceType: .camera, image: .constant(nil))
            } else {
                Text("This feature is available for Pro users only.")
                    .padding()
            }
        }
        .onAppear {
            viewModel.fetchExpenses()
        }
        .onChange(of: showingAddExpenseView) { isPresented in
            if !isPresented {
                viewModel.fetchExpenses()
            }
        }
        .onChange(of: viewModel.visibleExpenseIds) { _ in
            viewModel.updateDisplayedPeriodAndTotal()
        }
    }

    private var expenseRows: some View {
        ForEach(viewModel.expenses) { expense in
            if let expenseId = expense.id {
                NavigationLink(destination: ExpenseDetailView(expense: expense, userViewModel: userViewModel, onSave: {
                    viewModel.fetchExpenses()
                })) {
                    ExpenseRow(expense: expense)
                }
                .trackVisibility(visibleExpenseIds: $viewModel.visibleExpenseIds, expenseId: expenseId)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(action: {
                        withAnimation {
                            viewModel.deleteExpense(expense)
                        }
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
                .swipeActions(edge: .leading) {
                    Button(action: {
                        editingExpense = expense
                        showingAddExpenseView.toggle()
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.yellow)
                }
            }
        }
    }

    private var addButton: some View {
        Button(action: {
            showingActionSheet.toggle()
        }) {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
                .opacity(0.7)
        }
        .padding()
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text("Select Action"), buttons: [
                .default(Text("New Entry")) {
                    showingAddExpenseView.toggle()
                },
                .default(Text("Camera")) {
                    showingCameraView.toggle()
                },
                .cancel()
            ])
        }
    }
}

struct ExpenseListView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseListView(
            viewModel: ExpenseViewModel(viewContext: PersistenceController.preview.container.viewContext),
            userViewModel: UserViewModel(),
            editingExpense: .constant(nil),
            showingAddExpenseView: .constant(false),
            showingAnalyseView: .constant(false),
            showingSettingsView: .constant(false),
            showingActionSheet: .constant(false),
            showingCameraView: .constant(false)
        )
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
