import SwiftUI
import CoreData

struct DetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedView: SelectedView?
    @ObservedObject var viewModel: ExpenseViewModel
    @Binding var editingExpense: Expense?
    @Binding var showingAddExpenseView: Bool
    @Binding var showingActionSheet: Bool
    @Binding var showingCameraView: Bool
    
    var body: some View {
        VStack {
            if selectedView == .expenses {
                ExpenseListView(viewModel: viewModel, editingExpense: $editingExpense, showingAddExpenseView: $showingAddExpenseView, showingActionSheet: $showingActionSheet, showingCameraView: $showingCameraView)
            } else if selectedView == .analyse {
                iPadAnalyseView()
            } else if selectedView == .settings {
                iPadSettingsView()
            } else {
                Text("Select an option from the menu.")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(
            selectedView: .constant(.expenses),
            viewModel: ExpenseViewModel(viewContext: PersistenceController.preview.container.viewContext),
            editingExpense: .constant(nil),
            showingAddExpenseView: .constant(false),
            showingActionSheet: .constant(false),
            showingCameraView: .constant(false)
        )
    }
}
