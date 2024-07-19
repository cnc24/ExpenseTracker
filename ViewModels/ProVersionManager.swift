import Foundation
import StoreKit

class ProVersionManager: NSObject, ObservableObject {
    static let shared = ProVersionManager()
    
    @Published var isProVersionUnlocked = false
    private var products: [SKProduct] = []
    private var productRequest: SKProductsRequest?
    
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
        checkProStatus()
        
        isProVersionUnlocked = true
    }
    
    func fetchProducts() {
        let productIdentifiers = Set(["com.yourcompany.yourapp.ProVersion"])
        productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest?.delegate = self
        productRequest?.start()
    }
    
    func purchaseProVersion() {
        guard let product = products.first else { return }
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    private func checkProStatus() {
        // Hier kannst du den Pro-Status aus dem Benutzer-Defaults oder einer anderen persistenten Speicherlösung überprüfen
        let isPro = UserDefaults.standard.bool(forKey: "isProUser")
        isProVersionUnlocked = isPro
    }
    
    private func saveProStatus() {
        UserDefaults.standard.set(isProVersionUnlocked, forKey: "isProUser")
    }
}

extension ProVersionManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
    }
}

extension ProVersionManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                isProVersionUnlocked = true
                saveProStatus()
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                if let error = transaction.error {
                    print("Transaction failed: \(error.localizedDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
}
