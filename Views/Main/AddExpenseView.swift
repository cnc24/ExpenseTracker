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
    @State private var recognizedText = ""
    @State private var showProFeature = false
    
    @FetchRequest(entity: Expense.entity(), sortDescriptors: []) private var allExpenses: FetchedResults<Expense>
    
    var expenseToEdit: Expense?

    init(viewModel: ExpenseViewModel, userViewModel: UserViewModel, expenseToEdit: Expense? = nil) {
        self.viewModel = viewModel
        self.userViewModel = userViewModel
        self.expenseToEdit = expenseToEdit
        
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

    var body: some View {
        NavigationView {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.horizontal)
                } else {
                    Button(action: {
                        if userViewModel.isProUser {
                            showingImagePicker.toggle()
                        } else {
                            // Show alert or message that this feature is only for Pro users
                            showProFeatureAlert()
                        }
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
                        .padding(.horizontal)
                    }
                }

                ScrollView {
                    VStack(spacing: 20) {
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
            }
            .navigationBarTitle(expenseToEdit == nil ? "Ausgabe hinzufügen" : "Ausgabe bearbeiten", displayMode: .inline)
            .navigationBarItems(trailing: Button("Speichern") {
                addItem()
            })
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(sourceType: .camera, image: $image) { recognizedText in
                    self.recognizedText = recognizedText
                    let extractedData = extractData(from: recognizedText)
                    self.amount = extractedData.amount ?? ""
                    self.location = extractedData.location ?? ""
                    if let dateString = extractedData.date {
                        self.date = parseDate(from: dateString) ?? self.date
                    }
                }
            }
            .sheet(isPresented: $showingCategoryPicker) {
                EditCategoriesView(selectedCategories: $selectedCategories)
                    .environment(\.managedObjectContext, viewContext)
            }
            .alert(isPresented: $showProFeature) {
                Alert(title: Text("Pro Feature"), message: Text("Diese Funktion ist nur für Pro-Benutzer verfügbar. Bitte erwerben Sie die Pro-Version, um diese Funktion zu nutzen."), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func showProFeatureAlert() {
        showProFeature = true
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
    
    private func extractData(from text: String) -> (amount: String?, location: String?, date: String?) {
        // Beispielhafte Regular Expressions - anpassen für spezifische Anforderungen
        let amountRegex = try! NSRegularExpression(pattern: "\\b\\d+[,.]\\d{2}\\b")
        let dateRegex = try! NSRegularExpression(pattern: "\\b\\d{2}[./-]\\d{2}[./-]\\d{2,4}\\b")
        let locationRegex = try! NSRegularExpression(pattern: "(Ort|Location|Adresse|Street):\\s*(\\w+)")

        let amountMatch = amountRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text))
        let dateMatch = dateRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text))
        let locationMatch = locationRegex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text))

        let amount = amountMatch.map { String(text[Range($0.range, in: text)!]) }
        let date = dateMatch.map { String(text[Range($0.range, in: text)!]) }
        let location = locationMatch.map { String(text[Range($0.range(at: 2), in: text)!]) }

        return (amount, location, date)
    }

    private func parseDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.date(from: dateString)
    }
    
    private func fetchSuggestions(for keyPath: KeyPath<Expense, String?>, filter: String) -> [String] {
        let values = allExpenses.compactMap { $0[keyPath: keyPath] }
        let uniqueValues = Set(values)
        return Array(uniqueValues).filter { $0.lowercased().contains(filter.lowercased()) }
    }
}

struct AddExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExpenseView(viewModel: ExpenseViewModel(viewContext: PersistenceController.preview.container.viewContext), userViewModel: UserViewModel())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
