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
                VStack(alignment: .leading, spacing: 28) {
                    PaywallHero(price: productPrice)
                    PaywallValueCard(price: productPrice)

                    PaywallFeatureSection(
                        icon: "clock.arrow.circlepath",
                        title: "Historique étendu",
                        question: "Vous comparez souvent plusieurs devis ou prix.",
                        value: "La version Pro garde les calculs importants sous la main, localement sur l'iPhone.",
                        example: "Exemple : retrouver rapidement un ancien objectif net, une marge vérifiée ou un montant à facturer.",
                        detail: "Les quatre calculettes restent utilisables sans achat. Pro ajoute surtout du confort dans la durée."
                    )

                    PaywallFeatureSection(
                        icon: "list.bullet.rectangle",
                        title: "Détail des formules",
                        question: "Vous voulez comprendre d'où vient un résultat.",
                        value: "Pro affiche les lignes de calcul complètes, la formule utilisée, les avertissements et les sources internes du jeu de règles.",
                        example: "Exemple : voir la base HT, la TVA, les cotisations, le versement libératoire et la CFP dans une lecture séparée.",
                        detail: "Utile quand vous devez expliquer un prix, vérifier un paramètre ou relire une estimation avant un devis."
                    )

                    PaywallFeatureSection(
                        icon: "lock.shield.fill",
                        title: "App locale et maintenue",
                        question: "Pas de compte, pas de publicité, pas de backend.",
                        value: "Votre achat soutient une app française simple, locale, sans abonnement et maintenue quand les règles changent.",
                        example: "Exemple : les montants saisis restent sur l'iPhone, et l'achat passe par StoreKit 2.",
                        detail: "Pro finance surtout la maintenance invisible : tests, sources fiscales, corrections et amélioration de l'expérience."
                    )

                    PaywallIncludedSection()

                    if entitlementStore.purchaseState == .productUnavailable {
                        PaywallStatusMessage()
                    }

                    PaywallSupportSection()
                }
                .padding(.horizontal, 22)
                .padding(.top, 22)
                .padding(.bottom, 180)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Passer à la version Pro")
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
        .safeAreaInset(edge: .bottom) {
            PaywallActionBar(
                primaryTitle: primaryButtonTitle,
                restoreTitle: restoreButtonTitle,
                canPurchase: canPurchase,
                isBusy: isBusy,
                onPurchase: {
                    Task {
                        await entitlementStore.purchasePro()
                        if entitlementStore.isPro {
                            dismiss()
                        }
                    }
                },
                onRestore: {
                    Task {
                        await entitlementStore.restorePurchases()
                        if entitlementStore.isPro {
                            dismiss()
                        }
                    }
                }
            )
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
            return "Version Pro active"
        case .productUnavailable:
            return "Achat indisponible"
        case .idle, .restoring:
            return "Passer à la version Pro pour \(productPrice)"
        }
    }

    private var restoreButtonTitle: String {
        entitlementStore.purchaseState == .restoring ? "Restauration" : "Restaurer mes achats"
    }
}

private struct PaywallHero: View {
    let price: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Calculette Fiscale Pro")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.white)

                Text("Décidez quoi facturer sans vous raconter d'histoires.")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Les calculettes essentielles restent gratuites. La version Pro ajoute l'historique, les formules détaillées et le confort pour travailler plus souvent avec l'app.")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white.opacity(0.70))
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 10) {
                PaywallBadge(text: "\(price) une fois", systemImage: "checkmark.seal.fill")
                PaywallBadge(text: "Sans abonnement", systemImage: "creditcard.fill")
            }
        }
    }
}

private struct PaywallBadge: View {
    let text: String
    let systemImage: String

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.system(size: 13, weight: .semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 38)
            .background(Color.orange.opacity(0.18))
            .foregroundStyle(.orange)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct PaywallValueCard: View {
    let price: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pourquoi la version Pro vaut son prix")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)

            Text("\(price), une seule fois, pour garder vos calculs importants, relire les formules et soutenir une app sans publicité ni abonnement.")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white.opacity(0.88))
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 10) {
                PaywallValueRow(
                    title: "Les calculettes restent utiles en gratuit",
                    text: "TVA, Reste net, Objectif net et Marge simple sont accessibles sans achat."
                )

                PaywallValueRow(
                    title: "Plus de contexte quand il en faut",
                    text: "Pro ajoute l'historique et le détail complet pour relire un calcul au bon moment."
                )

                PaywallValueRow(
                    title: "Un achat unique",
                    text: "Pas d'abonnement. La restauration reste possible avec l'achat intégré Apple."
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.24),
                    Color.white.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct PaywallValueRow: View {
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.orange)
                .frame(width: 22, alignment: .leading)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)

                Text(text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.64))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PaywallFeatureSection: View {
    let icon: String
    let title: String
    let question: String
    let value: String
    let example: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 38, height: 38)
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Text(title)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text(question)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.orange)
                .fixedSize(horizontal: false, vertical: true)

            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white.opacity(0.88))
                .fixedSize(horizontal: false, vertical: true)

            Text(example)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.66))
                .fixedSize(horizontal: false, vertical: true)

            Text(detail)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.52))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct PaywallIncludedSection: View {
    private let items = [
        PaywallIncludedItem(
            id: "history",
            icon: "clock.arrow.circlepath",
            title: "Historique avancé",
            text: "Gardez vos scénarios sous la main pour comparer deux devis, revenir sur un client ou vérifier une marge sans tout ressaisir."
        ),
        PaywallIncludedItem(
            id: "formulas",
            icon: "list.bullet.rectangle",
            title: "Formules complètes",
            text: "Voyez d'où vient le résultat : lignes de calcul, avertissements et barèmes disponibles dans l'app."
        ),
        PaywallIncludedItem(
            id: "local",
            icon: "lock.shield.fill",
            title: "Confidentialité simple",
            text: "Pas de compte, pas de publicité, pas de backend. Les montants saisis restent sur l'iPhone."
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Ce que vous gagnez en plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(items) { item in
                    PaywallIncludedRow(item: item)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct PaywallIncludedItem: Identifiable {
    let id: String
    let icon: String
    let title: String
    let text: String
}

private struct PaywallIncludedRow: View {
    let item: PaywallIncludedItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.orange)
                .frame(width: 28, alignment: .leading)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Text(item.text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.60))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PaywallStatusMessage: View {
    var body: some View {
        Label(
            "Achat temporairement indisponible. Les calculettes de base restent gratuites et utilisables.",
            systemImage: "exclamationmark.triangle.fill"
        )
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(.orange)
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct PaywallSupportSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pourquoi payer une calculette ?")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)

            Text("Parce qu'une app de calcul n'a de valeur que si elle reste claire, fiable et maintenue. Passer à la version Pro soutient un développeur français indépendant, sans publicité et sans revente de données.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.68))
                .fixedSize(horizontal: false, vertical: true)

            Text("Votre achat finance surtout le travail invisible : surveiller les changements fiscaux, vérifier les sources officielles, corriger l'app et garder les chiffres à jour dans le temps.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.68))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct PaywallActionBar: View {
    let primaryTitle: String
    let restoreTitle: String
    let canPurchase: Bool
    let isBusy: Bool
    let onPurchase: () -> Void
    let onRestore: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Button(action: onPurchase) {
                Label(primaryTitle, systemImage: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(canPurchase ? Color.orange : Color.white.opacity(0.16))
                    .foregroundStyle(canPurchase ? Color.black : Color.white.opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!canPurchase)

            Button(action: onRestore) {
                Label(restoreTitle, systemImage: "arrow.clockwise")
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(Color.white.opacity(0.12))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(isBusy)

            Text("Achat unique. Pas d'abonnement. Restauration possible. Vos montants restent sur l'iPhone.")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.48))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 22)
        .padding(.top, 14)
        .padding(.bottom, 12)
        .background(.black)
    }
}

#Preview {
    let defaults = UserDefaults(suiteName: "calculette_fiscale.paywall.preview") ?? .standard
    let store = EntitlementStore(service: PreviewStoreKitService(), defaults: defaults)

    PaywallView(entitlementStore: store)
}
