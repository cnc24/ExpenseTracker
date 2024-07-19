import SwiftUI
import CoreData

struct iPhoneContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ExpenseViewModel
    @StateObject private var userViewModel: UserViewModel
    
    init(viewContext: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: ExpenseViewModel(viewContext: viewContext))
        _userViewModel = StateObject(wrappedValue: UserViewModel())
    }
    
    @State private var showingAddExpenseView = false
    @State private var showingCameraView = false
    @State private var showingActionSheet = false
    @State private var editingExpense: Expense? = nil
    @State private var showingAnalyseView = false
    @State private var showingSettingsView = false
    @State private var showingProAlert = false
    @State private var proAlertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                expenseList
                    .navigationBarTitle("Expenses", displayMode: .inline)
                    .navigationBarItems(
                        leading: leadingNavigationBarItems,
                        trailing: trailingNavigationBarItems
                    )   
            }
            .overlay(
                addButton,
                alignment: .bottomTrailing
            )
            .alert(isPresented: $showingProAlert) {
                Alert(title: Text("Pro Feature"),
                      message: Text(proAlertMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
        .sheet(isPresented: $showingAddExpenseView) {
            AddExpenseView(viewModel: viewModel, userViewModel: userViewModel, expenseToEdit: editingExpense)
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
        .fullScreenCover(isPresented: $showingAnalyseView) {
            if userViewModel.isProUser {
                AnalyseView()
            } else {
                Text("This feature is available for Pro users only.")
                    .padding()
            }
        }
        .sheet(isPresented: $showingSettingsView) {
            SettingsView()
                .environment(\.managedObjectContext, viewContext)
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
    
    private var expenseList: some View {
        List {
            ForEach(viewModel.expenses) { expense in
                if let expenseId = expense.id {
                    NavigationLink(destination: ExpenseDetailView(expense: expense, userViewModel: userViewModel, onSave: {
                        viewModel.fetchExpenses()
                    })) {
                        ExpenseRow(expense: expense)
                    }
                    .trackVisibility(visibleExpenseIds: $viewModel.visibleExpenseIds, expenseId: expenseId)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        deleteButton(for: expense)
                    }
                    .swipeActions(edge: .leading) {
                        editButton(for: expense)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private func deleteButton(for expense: Expense) -> some View {
        Button(action: {
            withAnimation {
                viewModel.deleteExpense(expense)
            }
        }) {
            Label("Delete", systemImage: "trash")
        }
        .tint(.red)
    }
    
    private func editButton(for expense: Expense) -> some View {
        Button(action: {
            editingExpense = expense
            showingAddExpenseView.toggle()
        }) {
            Label("Edit", systemImage: "pencil")
        }
        .tint(.yellow)
    }
    
    private var leadingNavigationBarItems: some View {
        Button(action: {
            viewModel.toggleTotalMode()
        }) {
            VStack(alignment: .leading) {
                Text(viewModel.displayedPeriod).bold()
                Text("\(viewModel.totalAmount, specifier: "%.2f") €")
            }
        }
    }
    
    private var trailingNavigationBarItems: some View {
        HStack {
            Button(action: {
                if userViewModel.isProUser {
                    showingAnalyseView.toggle()
                } else {
                    showProAlert(with: "This feature is available for Pro users only.")
                }
            }) {
                Image(systemName: "chart.bar")
            }
            Menu {
                Button(action: {
                    showingSettingsView.toggle()
                }) {
                    Text("Settings")
                }
            } label: {
                Image(systemName: "ellipsis")
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
                    if userViewModel.isProUser {
                        showingCameraView.toggle()
                    } else {
                        showProAlert(with: "This feature is available for Pro users only.")
                    }
                },
                .cancel()
            ])
        }
    }
    
    private func showProAlert(with message: String) {
        proAlertMessage = message
        showingProAlert = true
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

struct iPhoneContentView_Previews: PreviewProvider {
    static var previews: some View {
        iPhoneContentView(viewContext: PersistenceController.preview.container.viewContext)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
