import SwiftUI

struct SidebarView: View {
    @Binding var selectedView: iPadContentView.SidebarOption?

    var body: some View {
        List {
            Button(action: {
                selectedView = .expenses
            }) {
                Label("Expenses", systemImage: "list.bullet")
            }
            .tag(iPadContentView.SidebarOption.expenses)
            
            Button(action: {
                selectedView = .analyse
            }) {
                Label("Analyse", systemImage: "chart.bar")
            }
            .tag(iPadContentView.SidebarOption.analyse)
            
            Button(action: {
                selectedView = .settings
            }) {
                Label("Settings", systemImage: "gear")
            }
            .tag(iPadContentView.SidebarOption.settings)
        }
        .navigationTitle("Menu")
    }
}
