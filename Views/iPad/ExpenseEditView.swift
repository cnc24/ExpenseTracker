import SwiftUI
import CoreData
import Combine

struct ExpenseEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var purpose: String
    @State private var amount: String
    @State private var location: String
    @State private var notes: String
    @State private var date: Date
    @State private var image: UIImage?
    @State private var selectedCategories = Set<Category>()
    @State private var showingImagePicker = false
    @State private var showingPopover = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var currency: String
    
    var expense: Expense
    
    init(expense: Expense) {
        _purpose = State(initialValue: expense.purpose ?? "")
        _amount = State(initialValue: String(expense.amount))
        _location = State(initialValue: expense.location ?? "")
        _notes = State(initialValue: expense.notes ?? "")
        _date = State(initialValue: expense.date ?? Date())
        _image = State(initialValue: expense.image.flatMap { UIImage(data: $0) })
        _selectedCategories = State(initialValue: (expense.categories as? Set<Category>) ?? Set<Category>())
        _currency = State(initialValue: expense.currency ?? "€")
        self.expense = expense
    }
    
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
            .navigationTitle("Edit Expense")
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
        expense.purpose = purpose
        expense.amount = (amount as NSString).doubleValue
        expense.location = location
        expense.notes = notes
        expense.date = date
        expense.image = image?.jpegData(compressionQuality: 1.0)
        expense.categories = selectedCategories as NSSet
        expense.currency = currency
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to save expense: \(error.localizedDescription)")
        }
    }
}

struct ExpenseEditView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseEditView(expense: Expense.example)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
