import Foundation
import CoreData
import Combine
import UIKit

class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var visibleExpenseIds: Set<UUID> = []
    @Published var totalAmount: Double = 0.0
    @Published var showAnnualTotal = false
    @Published var displayedPeriod: String = ""
    
    private(set) var viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        fetchExpenses()
        
        $visibleExpenseIds
            .removeDuplicates()
            .sink { [weak self] visibleIds in
                guard let self = self else { return }
                let visibleExpenses = self.expenses.filter { expense in
                    if let id = expense.id {
                        return visibleIds.contains(id)
                    }
                    return false
                }
                self.calculateDisplayedPeriod(expenses: visibleExpenses)
                self.totalAmount = self.showAnnualTotal ? self.calculateAnnualTotal() : self.calculateTotalForVisiblePeriod(expenses: visibleExpenses)
            }
            .store(in: &cancellables)
    }
    
    func fetchExpenses() {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Expense.date, ascending: true)]
        
        do {
            expenses = try viewContext.fetch(request)
        } catch {
            print("Error fetching expenses: \(error)")
        }
    }
    
    func addExpense(date: Date, purpose: String, location: String, amount: Double, notes: String, categories: [String], image: UIImage?) {
        Expense.create(in: viewContext, date: date, purpose: purpose, location: location, amount: amount, notes: notes, categories: categories, image: image)
        fetchExpenses()
    }
    
    func updateExpense(expense: Expense, date: Date, purpose: String, location: String, amount: Double, notes: String, categories: [String], image: UIImage?) {
        Expense.update(expense: expense, date: date, purpose: purpose, location: location, amount: amount, notes: notes, categories: categories, image: image, in: viewContext)
        fetchExpenses()
    }
    
    func deleteExpense(_ expense: Expense) {
        viewContext.delete(expense)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
            fetchExpenses()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    private func calculateTotal(expenses: [Expense]) -> Double {
        return expenses.reduce(0) { $0 + $1.amount }
    }
    
    private func calculateTotalForVisiblePeriod(expenses: [Expense]) -> Double {
        return calculateTotal(expenses: expenses)
    }
    
    private func calculateAnnualTotal() -> Double {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let annualExpenses = expenses.filter {
            let year = calendar.component(.year, from: $0.date ?? Date())
            return year == currentYear
        }
        return calculateTotal(expenses: annualExpenses)
    }
    
    private func calculateDisplayedPeriod(expenses: [Expense]) {
        let calendar = Calendar.current
        let visibleDates = expenses.compactMap { $0.date }.sorted()
        
        if visibleDates.isEmpty {
            displayedPeriod = NSLocalizedString("No Expenses", comment: "No Expenses label")
            return
        }
        
        let firstVisibleMonth = calendar.component(.month, from: visibleDates.first!)
        let lastVisibleMonth = calendar.component(.month, from: visibleDates.last!)
        let firstVisibleYear = calendar.component(.year, from: visibleDates.first!)
        let lastVisibleYear = calendar.component(.year, from: visibleDates.last!)
        
        if firstVisibleYear == lastVisibleYear {
            if firstVisibleMonth == lastVisibleMonth {
                displayedPeriod = "\(calendar.monthSymbols[firstVisibleMonth - 1])"
            } else {
                displayedPeriod = "\(calendar.monthSymbols[firstVisibleMonth - 1]) - \(calendar.monthSymbols[lastVisibleMonth - 1])"
            }
        } else {
            displayedPeriod = "\(calendar.monthSymbols[firstVisibleMonth - 1]) \(firstVisibleYear) - \(calendar.monthSymbols[lastVisibleMonth - 1]) \(lastVisibleYear)"
        }
    }
    
    func toggleTotalMode() {
        showAnnualTotal.toggle()
        if showAnnualTotal {
            displayedPeriod = NSLocalizedString("Annual Total", comment: "Annual total label")
            totalAmount = calculateAnnualTotal()
        } else {
            let visibleExpenses = expenses.filter { expense in
                if let id = expense.id {
                    return visibleExpenseIds.contains(id)
                }
                return false
            }
            calculateDisplayedPeriod(expenses: visibleExpenses)
            totalAmount = calculateTotalForVisiblePeriod(expenses: visibleExpenses)
        }
    }
    
    func updateDisplayedPeriodAndTotal() {
        let visibleExpenses = expenses.filter { expense in
            if let id = expense.id {
                return visibleExpenseIds.contains(id)
            }
            return false
        }
        calculateDisplayedPeriod(expenses: visibleExpenses)
        totalAmount = showAnnualTotal ? calculateAnnualTotal() : calculateTotalForVisiblePeriod(expenses: visibleExpenses)
    }
    
    func getCategorySuggestions(for query: String) -> [String] {
        let allCategories = ["Food", "Travel", "Entertainment", "Utilities", "Shopping"] // Beispielkategorien
        return allCategories.filter { $0.localizedCaseInsensitiveContains(query) }
    }
}
