import SwiftUI
import CoreData

struct iPadSettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingResetConfirmation = false

    var body: some View {
        VStack {
            List {
                NavigationLink(destination: SignInView()) {
                    Text("Anmelden")
                }
                NavigationLink(destination: EditCategoriesView(selectedCategories: .constant(Set<String>()))) {
                    Text("Kategorien bearbeiten")
                }
                NavigationLink(destination: AboutView()) {
                    Text("Über die App")
                }
                NavigationLink(destination: ProVersionView()) {
                    Text("Pro Kaufen")
                }
                Button(action: {
                    showingResetConfirmation.toggle()
                }) {
                    Text("App zurücksetzen")
                        .foregroundColor(.red)
                }
            }
            .navigationBarTitle("Einstellungen", displayMode: .inline)
            .actionSheet(isPresented: $showingResetConfirmation, content: {
                ActionSheet(
                    title: Text(NSLocalizedString("Reset App", comment: "Label for reset app")),
                    message: Text(NSLocalizedString("Do you want to delete all data? This action can not be undone!", comment: "warning label")),
                    buttons: [
                        .destructive(Text(NSLocalizedString("Delete", comment: "label for delete"))){
                            resetApp()
                        },
                        .cancel()
                    ]
                )
            })
        }
    }

    private func resetApp() {
        PersistenceController.shared.resetApp()
    }
}

struct iPadSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        iPadSettingsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
