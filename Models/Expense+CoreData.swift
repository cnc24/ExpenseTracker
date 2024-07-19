import Foundation
import CoreData
import UIKit

extension Expense {
    
    static func create(in context: NSManagedObjectContext, date: Date, purpose: String, location: String, amount: Double, notes: String, categories: [String], image: UIImage?) {
        let newExpense = Expense(context: context)
        newExpense.id = UUID()
        newExpense.date = date
        newExpense.purpose = purpose
        newExpense.location = location
        newExpense.amount = amount
        newExpense.notes = notes
        
        if let image = image, let imageData = image.jpegData(compressionQuality: 1.0) {
            newExpense.image = imageData
        }
        
        for categoryName in categories {
            let categoryFetch: NSFetchRequest<Category> = Category.fetchRequest()
            categoryFetch.predicate = NSPredicate(format: "name == %@", categoryName)

            do {
                if let existingCategory = try context.fetch(categoryFetch).first {
                    newExpense.addToCategories(existingCategory)
                } else {
                    let newCategory = Category(context: context)
                    newCategory.name = categoryName
                    newExpense.addToCategories(newCategory)
                }
            } catch {
                print("Error fetching category: \(error)")
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }

    static func update(expense: Expense, date: Date, purpose: String, location: String, amount: Double, notes: String, categories: [String], image: UIImage?, in context: NSManagedObjectContext) {
           expense.date = date
           expense.purpose = purpose
           expense.location = location
           expense.amount = amount
           expense.notes = notes
           
           if let image = image, let imageData = image.jpegData(compressionQuality: 1.0) {
               expense.image = imageData
           }
           
           // Entferne bestehende Kategorien, bevor neue hinzugefügt werden
           if let existingCategories = expense.categories as? Set<Category> {
               for category in existingCategories {
                   expense.removeFromCategories(category)
               }
           }
           
           for categoryName in categories {
               let categoryFetch: NSFetchRequest<Category> = Category.fetchRequest()
               categoryFetch.predicate = NSPredicate(format: "name == %@", categoryName)

               do {
                   if let existingCategory = try context.fetch(categoryFetch).first {
                       expense.addToCategories(existingCategory)
                   } else {
                       let newCategory = Category(context: context)
                       newCategory.name = categoryName
                       expense.addToCategories(newCategory)
                   }
               } catch {
                   print("Error fetching category: \(error)")
               }
           }
           
           do {
               try context.save()
           } catch {
               print("Error saving context: \(error)")
           }
    }

    static var example: Expense {
            let context = PersistenceController.preview.container.viewContext
            let expense = Expense(context: context)
            expense.id = UUID()
            expense.date = Date()
            expense.purpose = "Sample Purpose"
            expense.location = "Sample Location"
            expense.amount = 123.45
            expense.notes = "Sample Notes"
            expense.image = UIImage(systemName: "photo")?.jpegData(compressionQuality: 1.0)
            
            // Beispielkategorien hinzufügen
            let category1 = Category(context: context)
            category1.name = "Food"
            
            let category2 = Category(context: context)
            category2.name = "Transport"
            
            expense.addToCategories(category1)
            expense.addToCategories(category2)
            
            return expense
        }
}
