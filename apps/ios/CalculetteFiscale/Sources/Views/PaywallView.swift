import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss

    let entitlementStore: EntitlementStore

    private var productPrice: String {
        entitlementStore.proProduct?.displayPrice ?? "9,99 €"
    }

    private var isBusy: Bool {
        entitlementStore.purchaseState == .purchasing
            || entitlementStore.purchaseState == .restoring
            || entitlementStore.purchaseState == .loadingProduct
    }

    private var canPurchase: Bool {
        entitlementStore.proProduct != nil && !isBusy
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Calculette Fiscale Pro")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundStyle(.white)

                        Text("Un achat unique pour débloquer les modes avancés.")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.white.opacity(0.68))
                    }

                    VStack(spacing: 12) {
                        PaywallBenefitRow(
                            systemImage: "checkmark.seal.fill",
                            title: "Achat unique \(productPrice)",
                            subtitle: "Pas d'abonnement et pas de publicité."
                        )
                        PaywallBenefitRow(
                            systemImage: "lock.shield.fill",
                            title: "Calculs locaux",
                            subtitle: "Aucun backend et aucun montant saisi envoyé."
                        )
                        PaywallBenefitRow(
                            systemImage: "function",
                            title: "Modes avancés",
                            subtitle: "Indépendant, Objectif net, Marge, historique et formules complètes."
                        )
                    }

                    if entitlementStore.purchaseState == .productUnavailable {
                        Text("Achat indisponible temporairement. Le mode TVA reste utilisable.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.orange)
                    }

                    VStack(spacing: 12) {
                        Button {
                            Task {
                                await entitlementStore.purchasePro()
                                if entitlementStore.isPro {
                                    dismiss()
                                }
                            }
                        } label: {
                            Label(primaryButtonTitle, systemImage: "sparkles")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity, minHeight: 52)
                                .background(canPurchase ? Color.orange : Color.white.opacity(0.16))
                                .foregroundStyle(canPurchase ? Color.black : Color.white.opacity(0.55))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .disabled(!canPurchase)

                        Button {
                            Task {
                                await entitlementStore.restorePurchases()
                                if entitlementStore.isPro {
                                    dismiss()
                                }
                            }
                        } label: {
                            Label(restoreButtonTitle, systemImage: "arrow.clockwise")
                                .font(.system(size: 15, weight: .semibold))
                                .frame(maxWidth: .infinity, minHeight: 48)
                                .background(Color.white.opacity(0.12))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .disabled(isBusy)
                    }
                }
                .padding(24)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Passer à Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
        .task {
            await entitlementStore.loadProducts()
        }
    }

    private var primaryButtonTitle: String {
        switch entitlementStore.purchaseState {
        case .loadingProduct:
            return "Chargement"
        case .purchasing:
            return "Achat en cours"
        case .purchased:
            return "Pro actif"
        case .productUnavailable:
            return "Achat indisponible"
        case .idle, .restoring:
            return "Passer à Pro"
        }
    }

    private var restoreButtonTitle: String {
        entitlementStore.purchaseState == .restoring ? "Restauration" : "Restaurer mes achats"
    }
}

private struct PaywallBenefitRow: View {
    let systemImage: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.orange)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.58))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    let defaults = UserDefaults(suiteName: "calculette_fiscale.paywall.preview") ?? .standard
    let store = EntitlementStore(service: PreviewStoreKitService(), defaults: defaults)

    PaywallView(entitlementStore: store)
}
