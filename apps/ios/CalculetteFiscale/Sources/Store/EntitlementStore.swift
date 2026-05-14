import Foundation
import Observation

@MainActor
@Observable
final class EntitlementStore {
    static let proEntitlementCacheKey = "calculette_fiscale.pro_lifetime.entitled.v1"

    @ObservationIgnored private let service: StoreKitServicing
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private var transactionTasks: [Task<Void, Never>] = []

    private(set) var isPro: Bool
    private(set) var purchaseState: PurchaseState = .idle
    private(set) var proProduct: StoreProduct?

    convenience init(defaults: UserDefaults = .standard) {
        self.init(service: StoreKitService(), defaults: defaults)
    }

    init(
        service: StoreKitServicing,
        defaults: UserDefaults = .standard
    ) {
        self.service = service
        self.defaults = defaults
        isPro = defaults.bool(forKey: Self.proEntitlementCacheKey)
    }

    func start() {
        guard transactionTasks.isEmpty else {
            return
        }

        transactionTasks = [
            Task { await loadProducts() },
            Task { await refreshEntitlements() },
            Task { await consume(service.unfinishedTransactions()) },
            Task { await consume(service.transactionUpdates()) }
        ]
    }

    func loadProducts() async {
        guard purchaseState != .purchasing && purchaseState != .restoring else {
            return
        }

        purchaseState = .loadingProduct

        do {
            let products = try await service.loadProducts([StoreProductID.proLifetime])
            proProduct = products.first { $0.id == StoreProductID.proLifetime }
            purchaseState = proProduct == nil ? .productUnavailable : .idle
        } catch {
            proProduct = nil
            purchaseState = .productUnavailable
        }
    }

    func purchasePro() async {
        guard !isPro else {
            purchaseState = .purchased
            return
        }

        if proProduct == nil {
            await loadProducts()
        }

        guard proProduct != nil else {
            purchaseState = .productUnavailable
            return
        }

        purchaseState = .purchasing

        do {
            let result = try await service.purchase(productID: StoreProductID.proLifetime)

            switch result {
            case .purchased(let entitlement):
                apply(entitlement)
                purchaseState = isPro ? .purchased : .idle
            case .productUnavailable:
                purchaseState = .productUnavailable
            case .pending, .userCancelled, .unverified:
                purchaseState = .idle
            }
        } catch {
            purchaseState = .idle
        }
    }

    func restorePurchases() async {
        purchaseState = .restoring

        do {
            try await service.restorePurchases()
            await refreshEntitlements()
            purchaseState = isPro ? .purchased : .idle
        } catch {
            purchaseState = .idle
        }
    }

    func refreshEntitlements() async {
        var hasVerifiedPro = false

        for await entitlement in service.currentEntitlements() {
            guard entitlement.productID == StoreProductID.proLifetime else {
                continue
            }

            switch entitlement.state {
            case .active:
                hasVerifiedPro = true
            case .revoked:
                hasVerifiedPro = false
            case .unverified:
                break
            }
        }

        setPro(hasVerifiedPro)
    }

    private func consume(_ stream: AsyncStream<StoreEntitlement>) async {
        for await entitlement in stream {
            apply(entitlement)
        }
    }

    private func apply(_ entitlement: StoreEntitlement) {
        guard entitlement.productID == StoreProductID.proLifetime else {
            return
        }

        switch entitlement.state {
        case .active:
            setPro(true)
        case .revoked:
            setPro(false)
        case .unverified:
            break
        }
    }

    private func setPro(_ value: Bool) {
        isPro = value
        defaults.set(value, forKey: Self.proEntitlementCacheKey)
    }
}

@MainActor
final class PreviewStoreKitService: StoreKitServicing {
    func loadProducts(_ productIDs: Set<String>) async throws -> [StoreProduct] {
        guard productIDs.contains(StoreProductID.proLifetime) else {
            return []
        }

        return [
            StoreProduct(
                id: StoreProductID.proLifetime,
                displayName: "Calculette Fiscale Pro",
                displayPrice: "9,99 €"
            )
        ]
    }

    func purchase(productID: String) async throws -> StorePurchaseResult {
        .userCancelled
    }

    func restorePurchases() async throws {}

    func currentEntitlements() -> AsyncStream<StoreEntitlement> {
        AsyncStream { continuation in
            continuation.finish()
        }
    }

    func unfinishedTransactions() -> AsyncStream<StoreEntitlement> {
        AsyncStream { continuation in
            continuation.finish()
        }
    }

    func transactionUpdates() -> AsyncStream<StoreEntitlement> {
        AsyncStream { continuation in
            continuation.finish()
        }
    }
}
