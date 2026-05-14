import Foundation
import StoreKit

@MainActor
protocol StoreKitServicing: AnyObject {
    func loadProducts(_ productIDs: Set<String>) async throws -> [StoreProduct]
    func purchase(productID: String) async throws -> StorePurchaseResult
    func restorePurchases() async throws
    func currentEntitlements() -> AsyncStream<StoreEntitlement>
    func unfinishedTransactions() -> AsyncStream<StoreEntitlement>
    func transactionUpdates() -> AsyncStream<StoreEntitlement>
}

@MainActor
final class StoreKitService: StoreKitServicing {
    private var productsByID: [String: Product] = [:]

    func loadProducts(_ productIDs: Set<String>) async throws -> [StoreProduct] {
        let products = try await Product.products(for: Array(productIDs))

        products.forEach { product in
            productsByID[product.id] = product
        }

        return products
            .map { product in
                StoreProduct(
                    id: product.id,
                    displayName: product.displayName,
                    displayPrice: product.displayPrice
                )
            }
            .sorted { $0.id < $1.id }
    }

    func purchase(productID: String) async throws -> StorePurchaseResult {
        if productsByID[productID] == nil {
            _ = try await loadProducts([productID])
        }

        guard let product = productsByID[productID] else {
            return .productUnavailable
        }

        let result = try await product.purchase()

        switch result {
        case .success(let verificationResult):
            guard let entitlement = await Self.entitlement(from: verificationResult) else {
                return .unverified
            }

            return entitlement.state == .active ? .purchased(entitlement) : .unverified
        case .pending:
            return .pending
        case .userCancelled:
            return .userCancelled
        @unknown default:
            return .unverified
        }
    }

    func restorePurchases() async throws {
        try await AppStore.sync()
    }

    func currentEntitlements() -> AsyncStream<StoreEntitlement> {
        AsyncStream { continuation in
            Task {
                for await verificationResult in Transaction.currentEntitlements {
                    if let entitlement = await Self.entitlement(from: verificationResult) {
                        continuation.yield(entitlement)
                    }
                }

                continuation.finish()
            }
        }
    }

    func unfinishedTransactions() -> AsyncStream<StoreEntitlement> {
        AsyncStream { continuation in
            Task {
                for await verificationResult in Transaction.unfinished {
                    if let entitlement = await Self.entitlement(from: verificationResult) {
                        continuation.yield(entitlement)
                    }
                }

                continuation.finish()
            }
        }
    }

    func transactionUpdates() -> AsyncStream<StoreEntitlement> {
        AsyncStream { continuation in
            Task {
                for await verificationResult in Transaction.updates {
                    if let entitlement = await Self.entitlement(from: verificationResult) {
                        continuation.yield(entitlement)
                    }
                }

                continuation.finish()
            }
        }
    }

    private static func entitlement(
        from verificationResult: VerificationResult<Transaction>
    ) async -> StoreEntitlement? {
        switch verificationResult {
        case .verified(let transaction):
            let state: StoreEntitlementState = transaction.revocationDate == nil ? .active : .revoked
            await transaction.finish()
            return StoreEntitlement(productID: transaction.productID, state: state)
        case .unverified(let transaction, _):
            return StoreEntitlement(productID: transaction.productID, state: .unverified)
        }
    }
}
