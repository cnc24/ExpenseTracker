import SwiftUI
import UIKit
import CoreData

struct AddExpenseView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var viewModel: ExpenseViewModel
    @ObservedObject var userViewModel: UserViewModel
    @State private var date = Date()
    @State private var purpose = ""
    @State private var location = ""
    @State private var amount = ""
    @State private var notes = ""
    @State private var image: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var showingCategoryPicker = false
    @State private var selectedCategories = Set<String>()

    var expenseToEdit: Expense?

    init(viewModel: ExpenseViewModel, expenseToEdit: Expense? = nil, userViewModel: UserViewModel) {
        self.viewModel = viewModel
        self.expenseToEdit = expenseToEdit
        self.userViewModel = userViewModel
        
        if let expense = expenseToEdit {
            _date = State(initialValue: expense.date ?? Date())
            _purpose = State(initialValue: expense.purpose ?? "")
            _location = State(initialValue: expense.location ?? "")
            _amount = State(initialValue: String(expense.amount))
            _notes = State(initialValue: expense.notes ?? "")
            if let imageData = expense.image {
                _image = State(initialValue: UIImage(data: imageData))
            }
            
            if let categories = expense.categories as? Set<Category> {
                _selectedCategories = State(initialValue: Set(categories.compactMap { $0.name }))
            }
        }
    }

    private func addItem() {
        let normalizedAmount = amount.replacingOccurrences(of: ",", with: ".")
        let categoryArray = Array(selectedCategories)
        if let expense = expenseToEdit {
            Expense.update(expense: expense, date: date, purpose: purpose, location: location, amount: Double(normalizedAmount) ?? 0.0, notes: notes, categories: categoryArray, image: image, in: viewContext)
        } else {
            Expense.create(in: viewContext, date: date, purpose: purpose, location: location, amount: Double(normalizedAmount) ?? 0.0, notes: notes, categories: categoryArray, image: image)
        }
        viewModel.fetchExpenses()
        presentationMode.wrappedValue.dismiss()
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(10)
                            .padding()
                            .frame(maxWidth: .infinity)
                    } else {
                        Button(action: {
                            showingImagePicker.toggle()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 200)
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                    Text("Bild auswählen")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    Group {
                        HStack {
                            Text("Datum")
                                .font(.headline)
                            Spacer()
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                        }
                    }
                    .padding(.horizontal)
                    
                    Group {
                        HStack {
                            TextField("Zweck", text: $purpose)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            TextField("Ort", text: $location)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            TextField("Betrag", text: $amount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            TextField("Notizen", text: $notes)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Kategorie auswählen", text: .constant(""))
                            .onTapGesture {
                                showingCategoryPicker.toggle()
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
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
                    }
                }
                .padding(.top)
            }
            .navigationBarTitle(expenseToEdit == nil ? "Ausgabe hinzufügen" : "Ausgabe bearbeiten", displayMode: .inline)
            .navigationBarItems(trailing: Button("Speichern") {
                addItem()
            })
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(sourceType: .photoLibrary, image: $image)
            }
            .sheet(isPresented: $showingCategoryPicker) {
                EditCategoriesView(selectedCategories: $selectedCategories)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}

struct AddExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExpenseView(viewModel: ExpenseViewModel(viewContext: PersistenceController.preview.container.viewContext), userViewModel: UserViewModel())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
