import SwiftUI
import CoreData
import Combine

struct ExpenseAddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var purpose: String = ""
    @State private var amount: String = ""
    @State private var location: String = ""
    @State private var notes: String = ""
    @State private var date: Date = Date()
    @State private var image: UIImage? = nil
    @State private var selectedCategories = Set<Category>()
    @State private var showingImagePicker = false
    @State private var showingPopover = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var currency: String = "€"
    
    var categories: [Category] {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        return (try? viewContext.fetch(fetchRequest)) ?? []
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Purpose")) {
                    TextField("Purpose", text: $purpose)
                }
                Section(header: Text("Amount")) {
                    HStack {
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .modifier(FixedCommaModifier())
                        Picker("Currency", selection: $currency) {
                            ForEach(Locale.commonISOCurrencyCodes, id: \.self) { code in
                                Text(code).tag(code)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                Section(header: Text("Location")) {
                    TextField("Location", text: $location)
                }
                Section(header: Text("Notes")) {
                    TextField("Notes", text: $notes)
                }
                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                Section(header: Text("Categories")) {
                    List(categories, id: \.self) { category in
                        MultipleSelectionRow(title: category.name ?? "", isSelected: selectedCategories.contains(category)) {
                            if selectedCategories.contains(category) {
                                selectedCategories.remove(category)
                            } else {
                                selectedCategories.insert(category)
                            }
                        }
                    }
                }
                Section(header: Text("Image")) {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .clipped()
                    } else {
                        Button("Add Image") {
                            showingPopover = true
                        }
                        .popover(isPresented: $showingPopover) {
                            VStack(spacing: 20) {
                                Button(action: {
                                    imagePickerSource = .photoLibrary
                                    showingPopover = false
                                    showingImagePicker = true
                                }) {
                                    Text("Photo Library")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                Button(action: {
                                    imagePickerSource = .camera
                                    showingPopover = false
                                    showingImagePicker = true
                                }) {
                                    Text("Camera")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                saveExpense()
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $image, sourceType: imagePickerSource)
            }
        }
    }
    
    private func saveExpense() {
        let newExpense = Expense(context: viewContext)
        newExpense.purpose = purpose
        newExpense.amount = (amount as NSString).doubleValue
        newExpense.location = location
        newExpense.notes = notes
        newExpense.date = date
        newExpense.image = image?.jpegData(compressionQuality: 1.0)
        newExpense.categories = selectedCategories as NSSet
        newExpense.currency = currency
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to save expense: \(error.localizedDescription)")
        }
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                if isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}

struct ExpenseAddView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseAddView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
