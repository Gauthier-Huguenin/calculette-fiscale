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
                        icon: "person.crop.circle.badge.checkmark",
                        title: "Net pro",
                        question: "Un montant encaissé n'est pas forcément un montant disponible.",
                        value: "La version Pro aide à passer du TTC au HT, puis à une estimation de net selon les profils pris en charge dans l'app.",
                        example: "Exemple : sur 1 200 € TTC facturés, vous distinguez ce qui relève de la TVA, du chiffre d'affaires et du net indicatif.",
                        detail: "La valeur pour une entreprise : garder une lecture claire des montants avant de décider, même quand le statut, le régime ou le contexte change."
                    )

                    PaywallFeatureSection(
                        icon: "target",
                        title: "Objectif net",
                        question: "Vous avez un objectif. Le prix à facturer doit suivre.",
                        value: "Vous partez d'un montant cible, la version Pro remonte vers un prix à proposer, avec estimation HT et TTC.",
                        example: "Exemple : vous devez couvrir 2 500 € sur une mission, un lot ou une prestation. Le calcul vous donne une base de prix plus rationnelle.",
                        detail: "Un seul devis mieux calibré peut couvrir le prix de la version Pro. Le vrai gain, c'est de ne plus décider avec une intuition trop basse."
                    )

                    PaywallFeatureSection(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Marge",
                        question: "Votre vente a l'air rentable en TTC. Est-ce encore vrai une fois la TVA sortie ?",
                        value: "La version Pro calcule achat HT, vente HT, marge, taux de marge, taux de marque et TVA nette.",
                        example: "Exemple : achat 72 € TTC, vente 120 € TTC. Vous voyez si le prix couvre le coût, la TVA et votre objectif de marge.",
                        detail: "Utile pour une boutique, une SAS, une SARL, un artisan ou un consultant : vérifier la rentabilité avant d'acheter, publier un prix ou accepter une remise."
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

                Text("Pour toutes les entreprises : SAS, SARL, micro, commerce, artisanat ou conseil. La version Pro transforme vos montants en décisions claires sur la TVA, les prix, le net et la marge.")
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

            Text("\(price), une seule fois, pour éviter les estimations au doigt mouillé au moment de fixer un prix, contrôler une marge ou préparer un devis.")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white.opacity(0.88))
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 10) {
                PaywallValueRow(
                    title: "Un prix plus facile à assumer",
                    text: "Vous ne choisissez plus un montant parce qu'il sonne bien. Vous voyez ce qu'il produit vraiment pour l'entreprise."
                )

                PaywallValueRow(
                    title: "Une décision avant l'erreur",
                    text: "Le bon moment pour vérifier une TVA, une marge ou un net, c'est avant le devis, la vente ou la remise."
                )

                PaywallValueRow(
                    title: "Un achat vite amorti",
                    text: "Si la version Pro vous évite de sous-facturer ne serait-ce que 10 €, l'achat est déjà couvert."
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
            "Achat temporairement indisponible. La TVA reste gratuite et utilisable.",
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
