import SwiftUI
import CoreData

struct CategoryPickerView: View {
    @Binding var selectedCategories: Set<String>
    @State private var searchText = ""
    @Environment(\.presentationMode) var presentationMode
    var viewContext: NSManagedObjectContext

    var allCategories: [Category] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }

    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return allCategories
        } else {
            return allCategories.filter { $0.name?.localizedCaseInsensitiveContains(searchText) ?? false }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("Kategorien durchsuchen", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                List(filteredCategories, id: \.self) { category in
                    Button(action: {
                        selectedCategories.insert(category.name ?? "")
                        searchText = ""
                    }) {
                        Text(category.name ?? "")
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
            .navigationBarTitle("Kategorie auswählen", displayMode: .inline)
            .navigationBarItems(trailing: Button("Fertig") {
                presentationMode.wrappedValue.dismiss()
            })
            .onDisappear {
                saveNewCategories()
            }
        }
    }
    
    private func saveNewCategories() {
        for category in selectedCategories {
            if !allCategories.contains(where: { $0.name == category }) {
                let newCategory = Category(context: viewContext)
                newCategory.name = category
                do {
                    try viewContext.save()
                } catch {
                    print("Error saving new category: \(error)")
                }
            }
        }
    }
}

struct CategoryPickerView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryPickerView(selectedCategories: .constant(["Lebensmittel"]), viewContext: PersistenceController.preview.container.viewContext)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
