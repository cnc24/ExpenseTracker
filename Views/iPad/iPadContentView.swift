import SwiftUI
import CoreData

struct iPadContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @StateObject private var viewModel: ExpenseViewModel
    @StateObject private var userViewModel: UserViewModel

    @State private var showingAddExpenseView = false
    @State private var showingCameraView = false
    @State private var showingActionSheet = false
    @State private var editingExpense: Expense? = nil
    @State private var selectedView: SidebarOption? = .expenses
    @State private var showingAnalyseView = false
    @State private var showingSettingsView = false
    @State private var showingProAlert = false
    @State private var proAlertMessage = ""

    enum SidebarOption: Hashable {
        case expenses
        case analyse
        case settings
    }

    init(viewContext: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: ExpenseViewModel(viewContext: viewContext))
        _userViewModel = StateObject(wrappedValue: UserViewModel())
    }

    var body: some View {
        NavigationView {
            SidebarView(selectedView: $selectedView)
            contentView(for: selectedView)
                .onAppear {
                    if selectedView == .expenses {
                        navigationBarItems(trailing: trailingNavigationBarItems)
                    }
                }
                .navigationBarItems(trailing: selectedView == .expenses ? AnyView(trailingNavigationBarItems) : AnyView(EmptyView()))
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .alert(isPresented: $showingProAlert) {
            Alert(title: Text("Pro Feature"),
                  message: Text(proAlertMessage),
                  dismissButton: .default(Text("OK")) {
                      selectedView = .expenses
                      UIApplication.shared.hideSidebar()
                  })
        }
        .onChange(of: selectedView) { _ in
            UIApplication.shared.hideSidebar()
        }
    }

    @ViewBuilder
    private func contentView(for option: SidebarOption?) -> some View {
        switch option {
        case .expenses:
            ExpenseListView(
                viewModel: viewModel,
                userViewModel: userViewModel,
                editingExpense: $editingExpense,
                showingAddExpenseView: $showingAddExpenseView,
                showingAnalyseView: $showingAnalyseView,
                showingSettingsView: $showingSettingsView,
                showingActionSheet: $showingActionSheet,
                showingCameraView: $showingCameraView
            )
            .environment(\.managedObjectContext, viewContext)
        case .analyse:
            if userViewModel.isProUser {
                iPadAnalyseView()
                    .environment(\.managedObjectContext, viewContext)
            } else {
                Color.clear.onAppear {
                    showProAlert(with: "This feature is available for Pro users only.")
                }
            }
        case .settings:
            iPadSettingsView()
                .environment(\.managedObjectContext, viewContext)
        case .none:
            Text("Select an option from the menu.")
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
    }

    private var trailingNavigationBarItems: some View {
        Button(action: {
            viewModel.toggleTotalMode()
        }) {
            VStack(alignment: .leading) {
                Text(viewModel.displayedPeriod).bold()
                Text("\(viewModel.totalAmount, specifier: "%.2f") €")
            }
        }
    }
    
    private func showProAlert(with message: String) {
        DispatchQueue.main.async {
            proAlertMessage = message
            showingProAlert = true
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

struct iPadContentView_Previews: PreviewProvider {
    static var previews: some View {
        iPadContentView(viewContext: PersistenceController.preview.container.viewContext)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
