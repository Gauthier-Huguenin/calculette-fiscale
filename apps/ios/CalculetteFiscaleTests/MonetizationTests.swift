import XCTest
@testable import CalculetteFiscale

@MainActor
final class MonetizationTests: XCTestCase {
    func testCachedEntitlementLoadsLocalProState() {
        let defaults = isolatedDefaults()
        defaults.set(true, forKey: EntitlementStore.proEntitlementCacheKey)

        let store = EntitlementStore(service: MockStoreKitService(), defaults: defaults)

        XCTAssertTrue(store.isPro)
    }

    func testVerifiedCurrentEntitlementUnlocksPro() async {
        let service = MockStoreKitService()
        service.currentEntitlementsToYield = [
            StoreEntitlement(productID: StoreProductID.proLifetime, state: .active)
        ]
        let store = EntitlementStore(service: service, defaults: isolatedDefaults())

        await store.refreshEntitlements()

        XCTAssertTrue(store.isPro)
    }

    func testMissingCurrentEntitlementClearsCachedPro() async {
        let defaults = isolatedDefaults()
        defaults.set(true, forKey: EntitlementStore.proEntitlementCacheKey)
        let store = EntitlementStore(service: MockStoreKitService(), defaults: defaults)

        await store.refreshEntitlements()

        XCTAssertFalse(store.isPro)
        XCTAssertFalse(defaults.bool(forKey: EntitlementStore.proEntitlementCacheKey))
    }

    func testRevokedCurrentEntitlementLocksPro() async {
        let service = MockStoreKitService()
        service.currentEntitlementsToYield = [
            StoreEntitlement(productID: StoreProductID.proLifetime, state: .revoked)
        ]
        let defaults = isolatedDefaults()
        defaults.set(true, forKey: EntitlementStore.proEntitlementCacheKey)
        let store = EntitlementStore(service: service, defaults: defaults)

        await store.refreshEntitlements()

        XCTAssertFalse(store.isPro)
    }

    func testUnknownEntitlementDoesNotUnlockPro() async {
        let service = MockStoreKitService()
        service.currentEntitlementsToYield = [
            StoreEntitlement(productID: "other_product", state: .active)
        ]
        let store = EntitlementStore(service: service, defaults: isolatedDefaults())

        await store.refreshEntitlements()

        XCTAssertFalse(store.isPro)
    }

    func testUnverifiedEntitlementDoesNotUnlockPro() async {
        let service = MockStoreKitService()
        service.currentEntitlementsToYield = [
            StoreEntitlement(productID: StoreProductID.proLifetime, state: .unverified)
        ]
        let store = EntitlementStore(service: service, defaults: isolatedDefaults())

        await store.refreshEntitlements()

        XCTAssertFalse(store.isPro)
    }

    func testSuccessfulPurchaseUnlocksProImmediately() async {
        let service = MockStoreKitService()
        service.purchaseResult = .purchased(
            StoreEntitlement(productID: StoreProductID.proLifetime, state: .active)
        )
        let store = EntitlementStore(service: service, defaults: isolatedDefaults())

        await store.purchasePro()

        XCTAssertTrue(store.isPro)
        XCTAssertEqual(store.purchaseState, .purchased)
    }

    func testCancelledPurchaseStaysQuietAndLocked() async {
        let service = MockStoreKitService()
        service.purchaseResult = .userCancelled
        let store = EntitlementStore(service: service, defaults: isolatedDefaults())

        await store.purchasePro()

        XCTAssertFalse(store.isPro)
        XCTAssertEqual(store.purchaseState, .idle)
    }

    func testPendingPurchaseStaysLocked() async {
        let service = MockStoreKitService()
        service.purchaseResult = .pending
        let store = EntitlementStore(service: service, defaults: isolatedDefaults())

        await store.purchasePro()

        XCTAssertFalse(store.isPro)
        XCTAssertEqual(store.purchaseState, .idle)
    }

    func testThrownPurchaseErrorStaysQuietAndLocked() async {
        let service = MockStoreKitService()
        service.shouldThrowPurchase = true
        let store = EntitlementStore(service: service, defaults: isolatedDefaults())

        await store.purchasePro()

        XCTAssertFalse(store.isPro)
        XCTAssertEqual(store.purchaseState, .idle)
    }

    func testUnavailableProductDoesNotBreakFreeAccessPolicy() async {
        let service = MockStoreKitService()
        service.products = []
        let store = EntitlementStore(service: service, defaults: isolatedDefaults())

        await store.loadProducts()

        XCTAssertEqual(store.purchaseState, .productUnavailable)
        XCTAssertTrue(ProAccessPolicy.isAllowed(.mode(.vat), isPro: store.isPro))
    }

    func testProAccessPolicyLocksExpectedFeatures() {
        XCTAssertTrue(ProAccessPolicy.isAllowed(.mode(.vat), isPro: false))
        XCTAssertFalse(ProAccessPolicy.isAllowed(.mode(.independent), isPro: false))
        XCTAssertFalse(ProAccessPolicy.isAllowed(.mode(.netGoal), isPro: false))
        XCTAssertFalse(ProAccessPolicy.isAllowed(.mode(.margin), isPro: false))
        XCTAssertFalse(ProAccessPolicy.isAllowed(.history, isPro: false))
        XCTAssertFalse(ProAccessPolicy.isAllowed(.formulaDetails, isPro: false))

        XCTAssertTrue(ProAccessPolicy.isAllowed(.mode(.independent), isPro: true))
        XCTAssertTrue(ProAccessPolicy.isAllowed(.history, isPro: true))
        XCTAssertTrue(ProAccessPolicy.isAllowed(.formulaDetails, isPro: true))
    }

    private func isolatedDefaults() -> UserDefaults {
        let suiteName = "calculette_fiscale.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}

@MainActor
private final class MockStoreKitService: StoreKitServicing {
    var products: [StoreProduct] = [
        StoreProduct(
            id: StoreProductID.proLifetime,
            displayName: "Calculette Fiscale Pro",
            displayPrice: "9,99 €"
        )
    ]
    var purchaseResult: StorePurchaseResult = .userCancelled
    var currentEntitlementsToYield: [StoreEntitlement] = []
    var shouldThrowPurchase = false

    func loadProducts(_ productIDs: Set<String>) async throws -> [StoreProduct] {
        products.filter { productIDs.contains($0.id) }
    }

    func purchase(productID: String) async throws -> StorePurchaseResult {
        if shouldThrowPurchase {
            throw MockStoreKitError.purchaseFailed
        }

        return purchaseResult
    }

    func restorePurchases() async throws {}

    func currentEntitlements() -> AsyncStream<StoreEntitlement> {
        stream(from: currentEntitlementsToYield)
    }

    func unfinishedTransactions() -> AsyncStream<StoreEntitlement> {
        stream(from: [])
    }

    func transactionUpdates() -> AsyncStream<StoreEntitlement> {
        stream(from: [])
    }

    private func stream(from entitlements: [StoreEntitlement]) -> AsyncStream<StoreEntitlement> {
        AsyncStream { continuation in
            entitlements.forEach { continuation.yield($0) }
            continuation.finish()
        }
    }
}

private enum MockStoreKitError: Error {
    case purchaseFailed
}
