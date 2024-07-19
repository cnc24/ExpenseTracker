import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingResetConfirmation = false

    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: SignInView()) {
                    Text("Anmelden")
                }
                NavigationLink(destination: ProVersionView()) {
                    Text("Pro Kaufen")
                }
                NavigationLink(destination: AboutView()) {
                    Text("Über die App")
                }
                NavigationLink(destination: EditCategoriesView(selectedCategories: .constant(Set<String>()))) {
                    Text("Kategorien bearbeiten")
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
