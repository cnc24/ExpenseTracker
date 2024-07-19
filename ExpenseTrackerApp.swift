import SwiftUI

@main
struct ExpenseTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                iPadContentView(viewContext: viewContext)
            } else {
                iPhoneContentView(viewContext: viewContext)
            }
        }
    }
}
