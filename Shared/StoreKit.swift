
import Foundation
import StoreKit

//alias
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo //The Product.SubscriptionInfo.RenewalInfo provides information about the next subscription renewal period.
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState // the renewal states of auto-renewable subscriptions.

@MainActor
class StoreVM: ObservableObject {
    @Published private(set) var subscriptions: [Product] = []
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var subscriptionGroupStatus: RenewalState?
    @Published private(set) var purchasedProductIDs = Set<String>()
    
    private let productIds: [String] = ["monthly.subscription"]
    
    //var updateListenerTask : Task<Void, Error>? = nil
    
    private var updates: Task<Void, Never>? = nil

    init() {
        
        //start a transaction listern as close to app launch as possible so you don't miss a transaction
        //updateListenerTask = listenForTransactions()
        
        updates = observeTransactionUpdates()
        
        Task {
            await requestProducts()
            
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updates?.cancel()
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await verificationResult in Transaction.updates {
                // Using verificationResult directly would be better
                // but this way works for this tutorial
                await self.updatePurchasedProducts()
            }
        }
    }
    
//    func listenForTransactions() -> Task<Void, Error> {
//        return Task.detached {
//            //Iterate through any transactions that don't come from a direct call to `purchase()`.
//            for await result in Transaction.updates {
//                do {
//                    let transaction = try self.checkVerified(result)
//                    // deliver products to the user
//                    await self.updatePurchasedProducts()
//
//                    await transaction.finish()
//                } catch {
//                    print("transaction failed verification")
//                }
//            }
//        }
//    }
    
    
    
    // Request the products
    @MainActor
    func requestProducts() async {
        do {
            // request from the app store using the product ids (hardcoded)
            subscriptions = try await Product.products(for: productIds)
            //print(subscriptions)
        } catch {
            print("Failed product request from app store server: \(error)")
        }
    }
    
    // purchase the product
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
    
        switch result {
        case let .success(.verified(transaction)):
            await transaction.finish()
            await self.updatePurchasedProducts()
        case let .success(.unverified(_, error)):
            break
        case .pending:
            break
        case .userCancelled:
            break
        @unknown default:
            break
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
    
    var hasUnlockedPro: Bool {
        return !self.purchasedProductIDs.isEmpty
    }
    
//    @MainActor
//    func updateCustomerProductStatus() async {
//        for await result in Transaction.currentEntitlements {
//            do {
//                //Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
//                let transaction = try checkVerified(result)
//
//                switch transaction.productType {
//                    case .autoRenewable:
//                        if let subscription = subscriptions.first(where: {$0.id == transaction.productID}) {
//                            purchasedSubscriptions.append(subscription)
//                        }
//                    default:
//                        break
//                }
//                //Always finish a transaction.
//                await transaction.finish()
//            } catch {
//                print("failed updating products")
//            }
//        }
//    }
    
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
        print("updatePurchasedProducts called")
    }
    
    func restoreProducts(){
        print("restoreProducts called")
       SKPaymentQueue.default().restoreCompletedTransactions()
    }

}


public enum StoreError: Error {
    case failedVerification
}

