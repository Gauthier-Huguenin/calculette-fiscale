import Foundation

enum StoreProductID {
    static let proLifetime = "pro_lifetime"
}

struct StoreProduct: Equatable, Identifiable {
    let id: String
    let displayName: String
    let displayPrice: String
}

enum PurchaseState: Equatable {
    case idle
    case loadingProduct
    case productUnavailable
    case purchasing
    case restoring
    case purchased
}

enum StoreEntitlementState: Equatable {
    case active
    case revoked
    case unverified
}

struct StoreEntitlement: Equatable {
    let productID: String
    let state: StoreEntitlementState
}

enum StorePurchaseResult: Equatable {
    case purchased(StoreEntitlement)
    case pending
    case userCancelled
    case unverified
    case productUnavailable
}

enum ProFeature: Equatable {
    case mode(CalculationMode)
    case history
    case formulaDetails
}

enum ProAccessPolicy {
    static func requiresPro(_ feature: ProFeature) -> Bool {
        switch feature {
        case .mode(let mode):
            return mode.requiresPro
        case .history, .formulaDetails:
            return true
        }
    }

    static func isAllowed(_ feature: ProFeature, isPro: Bool) -> Bool {
        !requiresPro(feature) || isPro
    }
}

extension CalculationMode {
    var requiresPro: Bool {
        false
    }
}
