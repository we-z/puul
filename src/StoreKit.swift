
import Foundation
import StoreKit

@MainActor
class StoreVM: ObservableObject {
    @Published private(set) var subscriptions: [Product] = []
    @Published var purchasedProductIDs = Set<String>()
    @Published var success = false
    var model = AppModel()
    
    private let productIds: [String] = ["monthly.subscription"]
        
    var updateListenerTask : Task<Void, Error>? = nil

    init() {
        
        //start a transaction listern as close to app launch as possible so you don't miss a transaction
        
        updateListenerTask = listenForTransactions()
        
        Task {
            await requestProducts()
            
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            //Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    // deliver products to the user
                    await self.updatePurchasedProducts()
                    
                    await transaction.finish()
                } catch {
                    print("transaction failed verification")
                }
            }
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            //StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            //The result is verified. Return the unwrapped value.
            return safe
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
                success = true
                model.isPurchased = true
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
                model.isPurchased = false
            }
        }
    }
    
    @MainActor
    func restoreProducts() async {
        SKPaymentQueue.default().restoreCompletedTransactions()
        print("restoreProducts called")
        await updatePurchasedProducts()
    }

}

public enum StoreError: Error {
    case failedVerification
}
