
import Foundation
import StoreKit

@MainActor
class StoreVM: ObservableObject {
    @Published private(set) var subscriptions: [Product] = []
    @Published var purchasedProductIDs = Set<String>()
    @Published var success = false
    
    private let productIds: [String] = ["monthly.subscription"]
        
    private var updates: Task<Void, Never>? = nil

    init() {
        
        //start a transaction listern as close to app launch as possible so you don't miss a transaction
        
        updates = observeTransactionUpdates()
        
        Task {
            await requestProducts()
            
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updates?.cancel()
    }
    
    @MainActor
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in Transaction.updates {
                // Using verificationResult directly would be better
                // but this way works for this tutorial
                await self.updatePurchasedProducts()
            }
        }
    }
    
    // Request the products
    @MainActor
    func requestProducts() async {
        do {
            // request from the app store using the product ids (hardcoded)
            subscriptions = try await Product.products(for: productIds)
        } catch {
            print("Failed product request from app store server: \(error)")
        }
    }
    
    // purchase the product
    @MainActor
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        success = false
        switch result {
        case let .success(.verified(transaction)):
            await transaction.finish()
            await self.updatePurchasedProducts()
            success = true
        case .success(.unverified(_, _)):
            break
        case .pending:
            break
        case .userCancelled:
            break
        @unknown default:
            break
        }
    }
    
    var hasUnlockedPro: Bool {
        return !self.purchasedProductIDs.isEmpty
    }
    
    @MainActor
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }

            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
        }
    }
    
    @MainActor
    func restoreProducts(){
        print("restoreProducts called")
       SKPaymentQueue.default().restoreCompletedTransactions()
    }

}

