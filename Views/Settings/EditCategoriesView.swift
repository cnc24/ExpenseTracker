import SwiftUI
import CoreData

struct EditCategoriesView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
    ) private var categories: FetchedResults<Category>
    
    @State private var newCategoryName = ""
    @Binding var selectedCategories: Set<String>

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Kategorie hinzufügen oder suchen", text: $newCategoryName, onCommit: {
                        if !newCategoryName.isEmpty {
                            addOrSelectCategory(named: newCategoryName)
                            newCategoryName = ""
                        }
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        if !newCategoryName.isEmpty {
                            addOrSelectCategory(named: newCategoryName)
                            newCategoryName = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.green)
                    }
                }
                .padding()

                List {
                    ForEach(categories.filter { newCategoryName.isEmpty ? true : $0.name?.localizedCaseInsensitiveContains(newCategoryName) ?? false }) { category in
                        HStack {
                            Text(category.name ?? "Unbenannte Kategorie")
                            Spacer()
                            if selectedCategories.contains(category.name ?? "") {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleCategorySelection(named: category.name ?? "")
                        }
                    }
                }
                .listStyle(PlainListStyle())

                WrapView(data: Array(selectedCategories), id: \.self) { category in
                    HStack {
                        Text(category)
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        Button(action: {
                            selectedCategories.remove(category)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitle("Kategorien bearbeiten", displayMode: .inline)
            .navigationBarItems(trailing: Button("Fertig") {
                dismissView()
            })
        }
    }

    private func addOrSelectCategory(named categoryName: String) {
        if let existingCategory = categories.first(where: { $0.name?.localizedCaseInsensitiveCompare(categoryName) == .orderedSame }) {
            toggleCategorySelection(named: existingCategory.name ?? "")
        } else {
            let newCategory = Category(context: viewContext)
            newCategory.name = categoryName
            do {
                try viewContext.save()
                toggleCategorySelection(named: categoryName)
            } catch {
                print("Error adding category: \(error)")
            }
        }
    }

    private func toggleCategorySelection(named categoryName: String) {
        if selectedCategories.contains(categoryName) {
            selectedCategories.remove(categoryName)
        } else {
            selectedCategories.insert(categoryName)
        }
    }

    private func dismissView() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        EditCategoriesView(selectedCategories: .constant(Set<String>()))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
