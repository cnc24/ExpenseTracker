import CoreData
import UIKit

class PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        addSampleData(to: viewContext)
        return result
    }()

    let container: NSPersistentContainer
    private let userDefaults = UserDefaults.standard
    private let resetKey = "appHasBeenReset"

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ExpenseTracker")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { [weak self] storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            self?.addSampleDataIfNeeded(to: self!.container.viewContext)
        }
    }

    private func addSampleDataIfNeeded(to context: NSManagedObjectContext) {
        guard !userDefaults.bool(forKey: resetKey) else { return }

        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                PersistenceController.addSampleData(to: context)
            }
        } catch {
            print("Error checking if sample data is needed: \(error)")
        }
    }

    private static func addSampleData(to context: NSManagedObjectContext) {
        for monthOffset in 0..<6 {
            for _ in 0..<10 {
                let newExpense = Expense(context: context)
                newExpense.id = UUID()
                newExpense.date = Calendar.current.date(byAdding: .month, value: -monthOffset, to: Date())
                newExpense.purpose = "Sample Purpose \(monthOffset)"
                newExpense.location = "Sample Location"
                newExpense.amount = Double.random(in: 10...100)
                newExpense.notes = "Sample Notes"

                newExpense.image = UIImage(systemName: "photo")?.jpegData(compressionQuality: 1.0)
            }
        }

        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    func resetApp() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Expense.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try container.viewContext.execute(batchDeleteRequest)
            try container.viewContext.save()
            userDefaults.set(true, forKey: resetKey)
        } catch {
            print("Error resetting app: \(error)")
        }
    }
}
