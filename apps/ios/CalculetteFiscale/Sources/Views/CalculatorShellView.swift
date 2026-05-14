import SwiftUI
import UIKit

struct CalculatorShellView: View {
    @Environment(EntitlementStore.self) private var entitlementStore

    private let ruleSet = TaxRuleSet.french2026

    @State private var state = CalculatorViewState()
    @State private var isShowingDetails = false
    @State private var isShowingHistory = false
    @State private var isShowingPaywall = false
    @State private var isShowingSettings = false
    @State private var copyFeedback = false

    private var result: CalculationResult {
        state.currentResult(ruleSet: ruleSet)
    }

    var body: some View {
        GeometryReader { proxy in
            let keyHeight = min(68, max(62, proxy.size.height * 0.078))

            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 10) {
                    HeaderBar(
                        onHistory: openHistory,
                        isPro: entitlementStore.isPro,
                        historyCount: state.history.count
                    )

                    ModeSelector(
                        state: $state,
                        isPro: entitlementStore.isPro,
                        onLockedMode: { _ in showPaywall() }
                    )

                    Spacer(minLength: 4)

                    ResultPanel(
                        result: result,
                        activeFieldLabel: state.activeFieldLabel,
                        activeText: state.activeText,
                        activeVATRate: state.activeVATRate(ruleSet: ruleSet),
                        isCustomRateActive: state.activeEntryField == .customVATRate,
                        copyFeedback: copyFeedback,
                        onCopy: copyResult
                    )

                    PrimaryControls(
                        state: $state,
                        ruleSet: ruleSet,
                        onSettings: { isShowingSettings = true },
                        onDetails: openDetails,
                        isPro: entitlementStore.isPro
                    )

                    NumericKeypad(keyHeight: keyHeight) { key in
                        handleKey(key)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 10)
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: entitlementStore.isPro) { _, isPro in
            if isPro {
                isShowingPaywall = false
            } else if state.selectedMode.requiresPro {
                state.selectMode(.vat)
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            CalculationSettingsView(state: $state, ruleSet: ruleSet)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowingDetails) {
            CalculationDetailView(result: result, ruleSet: ruleSet)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowingHistory) {
            HistoryView(
                entries: state.history,
                onClear: { state.clearHistory() }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallView(entitlementStore: entitlementStore)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private func handleKey(_ key: String) {
        state.tapKey(key)

        if key == "=" && entitlementStore.isPro {
            state.addHistoryEntry(result: result)
        }
    }

    private func copyResult() {
        UIPasteboard.general.string = entitlementStore.isPro
            ? result.copyText
            : "\(result.mainLabel) : \(result.mainAmount.currencyText)"

        if entitlementStore.isPro {
            state.addHistoryEntry(result: result)
        }

        copyFeedback = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            copyFeedback = false
        }
    }

    private func openHistory() {
        guard entitlementStore.isPro else {
            showPaywall()
            return
        }

        isShowingHistory = true
    }

    private func openDetails() {
        guard entitlementStore.isPro else {
            showPaywall()
            return
        }

        isShowingDetails = true
    }

    private func showPaywall() {
        isShowingPaywall = true
    }
}

private struct HeaderBar: View {
    let onHistory: () -> Void
    let isPro: Bool
    let historyCount: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Calculette Fiscale")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Spacer()

            Button(action: onHistory) {
                Label(
                    isPro ? "\(historyCount)" : "Pro",
                    systemImage: isPro ? "clock.arrow.circlepath" : "lock.fill"
                )
                    .labelStyle(.titleAndIcon)
                    .font(.system(size: 14, weight: .semibold))
                    .frame(minWidth: 56, minHeight: 44)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .accessibilityLabel("Historique")
        }
    }
}

private struct ModeSelector: View {
    @Binding var state: CalculatorViewState
    let isPro: Bool
    let onLockedMode: (CalculationMode) -> Void

    var body: some View {
        HStack(spacing: 7) {
            ForEach(CalculationMode.allCases) { mode in
                Button {
                    if ProAccessPolicy.isAllowed(.mode(mode), isPro: isPro) {
                        state.selectMode(mode)
                    } else {
                        onLockedMode(mode)
                    }
                } label: {
                    HStack(spacing: 3) {
                        Text(mode.rawValue)
                            .lineLimit(1)
                            .minimumScaleFactor(0.68)

                        if mode.requiresPro && !isPro {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 9, weight: .bold))
                        }
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
                    .background(state.selectedMode == mode ? Color.white : Color.white.opacity(0.12))
                    .foregroundStyle(state.selectedMode == mode ? Color.black : Color.white.opacity(mode.requiresPro && !isPro ? 0.62 : 1))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(mode.requiresPro && !isPro ? "Mode \(mode.rawValue) verrouillé" : "Mode \(mode.rawValue)")
            }
        }
    }
}

private struct ResultPanel: View {
    let result: CalculationResult
    let activeFieldLabel: String
    let activeText: String
    let activeVATRate: Decimal
    let isCustomRateActive: Bool
    let copyFeedback: Bool
    let onCopy: () -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: 7) {
            HStack {
                Text(activeFieldLabel)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(isCustomRateActive ? Color.orange : Color.white.opacity(0.62))

                Spacer()

                Text("TVA \(activeVATRate.percentText)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.orange)
            }

            Text(isCustomRateActive ? "\(activeText) %" : activeText)
                .font(.system(size: 43, weight: .light, design: .rounded))
                .minimumScaleFactor(0.38)
                .lineLimit(1)
                .foregroundStyle(.white.opacity(0.70))

            Button(action: onCopy) {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(result.mainLabel)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.66))

                    Text(result.mainAmount.currencyText)
                        .font(.system(size: 54, weight: .light, design: .rounded))
                        .minimumScaleFactor(0.40)
                        .lineLimit(1)
                        .foregroundStyle(.white)

                    Label(copyFeedback ? "Copié" : "Toucher pour copier", systemImage: "doc.on.doc")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(copyFeedback ? Color.green : Color.white.opacity(0.48))
                }
                .frame(maxWidth: .infinity, minHeight: 88, alignment: .trailing)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Copier le résultat")
        }
    }
}

private struct PrimaryControls: View {
    @Binding var state: CalculatorViewState
    let ruleSet: TaxRuleSet
    let onSettings: () -> Void
    let onDetails: () -> Void
    let isPro: Bool

    var body: some View {
        VStack(spacing: 8) {
            ModeQuickControl(state: $state)

            HStack(spacing: 8) {
                SummaryPill(text: summaryText)

                ActionPill(
                    title: "Réglages",
                    systemImage: "slider.horizontal.3",
                    action: onSettings
                )
            }

            HStack(spacing: 8) {
                ActionPill(
                    title: isPro ? "Détail" : "Détail Pro",
                    systemImage: isPro ? "list.bullet.rectangle" : "lock.fill",
                    action: onDetails
                )

                PrimaryOptionButton(state: $state)
            }
        }
    }

    private var summaryText: String {
        let rate = state.activeVATRate(ruleSet: ruleSet).percentText

        switch state.selectedMode {
        case .vat:
            return "\(state.vatCalculationKind.rawValue) · TVA \(rate)"
        case .independent:
            return "\(profileShortLabel) · TVA \(rate) · \(state.vflEnabled ? "VFL" : "Hors IR")"
        case .netGoal:
            return "\(profileShortLabel) · TVA \(rate) · \(state.vflEnabled ? "VFL" : "Hors IR")"
        case .margin:
            return "\(state.activeMarginField.rawValue) · TVA \(rate) · \(state.vatDeductibleOnPurchase ? "Déductible" : "Non déductible")"
        }
    }

    private var profileShortLabel: String {
        switch state.selectedProfileId {
        case .microBICSale:
            return "Micro-BIC vente"
        case .microBICService:
            return "Micro-BIC prestation"
        case .microBNCServiceGeneral:
            return "Micro-BNC"
        }
    }
}

private struct ModeQuickControl: View {
    @Binding var state: CalculatorViewState

    var body: some View {
        switch state.selectedMode {
        case .vat:
            HStack(spacing: 7) {
                ForEach(VATCalculationKind.allCases) { kind in
                    CompactSegmentButton(
                        title: kind.rawValue,
                        isSelected: state.vatCalculationKind == kind,
                        action: {
                            state.vatCalculationKind = kind
                            state.activeEntryField = .amount
                        }
                    )
                }
            }
        case .independent:
            LargeToggleRow(
                title: "Franchise en base",
                subtitle: state.franchiseInBase ? "TVA non facturée" : "TVA facturée selon le taux actif",
                isOn: state.franchiseInBase,
                action: { state.toggleFranchiseInBase() }
            )
        case .netGoal:
            LargeToggleRow(
                title: "Versement libératoire",
                subtitle: state.vflEnabled ? "Inclus dans l'objectif net" : "Hors impôt sur le revenu",
                isOn: state.vflEnabled,
                action: { state.vflEnabled.toggle() }
            )
        case .margin:
            HStack(spacing: 7) {
                ForEach(MarginInputField.allCases) { field in
                    CompactSegmentButton(
                        title: field.rawValue,
                        isSelected: state.activeMarginField == field,
                        action: { state.selectMarginField(field) }
                    )
                }
            }
        }
    }
}

private struct PrimaryOptionButton: View {
    @Binding var state: CalculatorViewState

    var body: some View {
        switch state.selectedMode {
        case .vat:
            ActionPill(
                title: state.usesCustomVATRate ? "Perso" : "Taux",
                systemImage: "percent",
                action: { state.selectCustomVATRate() }
            )
        case .independent:
            ActionPill(
                title: state.amountKind.rawValue,
                systemImage: "arrow.left.arrow.right",
                action: { state.amountKind = state.amountKind == .ht ? .ttc : .ht }
            )
        case .netGoal:
            ActionPill(
                title: state.includeCFPInNetGoal ? "CFP incluse" : "CFP hors",
                systemImage: "checklist",
                action: { state.includeCFPInNetGoal.toggle() }
            )
        case .margin:
            ActionPill(
                title: state.vatDeductibleOnPurchase ? "TVA déductible" : "Sans déduction",
                systemImage: "arrow.down.doc",
                action: { state.vatDeductibleOnPurchase.toggle() }
            )
        }
    }
}

private struct SummaryPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.horizontal, 12)
            .background(Color.white.opacity(0.10))
            .foregroundStyle(.white.opacity(0.86))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct ActionPill: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .labelStyle(.titleAndIcon)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.74)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.horizontal, 10)
                .background(Color.white.opacity(0.12))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct CompactSegmentButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.70)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.horizontal, 8)
                .background(isSelected ? Color.orange : Color.white.opacity(0.12))
                .foregroundStyle(isSelected ? Color.black : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct LargeToggleRow: View {
    let title: String
    let subtitle: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                }

                Spacer()

                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isOn ? Color.orange : Color.white.opacity(0.50))
            }
            .frame(minHeight: 52)
            .padding(.horizontal, 14)
            .background(Color.white.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct CalculationSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var state: CalculatorViewState
    let ruleSet: TaxRuleSet

    var body: some View {
        NavigationStack {
            List {
                Section("TVA") {
                    ForEach(ruleSet.vatRates) { rate in
                        SettingOptionRow(
                            title: rate.label,
                            subtitle: "Taux officiel V1",
                            isSelected: !state.usesCustomVATRate && state.selectedVATRateId == rate.id,
                            action: { state.selectVATRate(id: rate.id) }
                        )
                    }

                    SettingOptionRow(
                        title: "Taux personnalisé",
                        subtitle: "Saisie au clavier fiscal",
                        isSelected: state.usesCustomVATRate,
                        action: {
                            state.selectCustomVATRate()
                            dismiss()
                        }
                    )
                }

                Section("Mode actif") {
                    modeSettings
                }

                Section("Prudence") {
                    Text("Barèmes vérifiés le 14/05/2026")
                        .font(.body.weight(.semibold))

                    Text("Estimation indicative. Cette calculette ne remplace pas une déclaration officielle ni un conseil adapté à votre situation.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Réglages du calcul")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private var modeSettings: some View {
        switch state.selectedMode {
        case .vat:
            ForEach(VATCalculationKind.allCases) { kind in
                SettingOptionRow(
                    title: kind.rawValue,
                    subtitle: "Sens du calcul TVA",
                    isSelected: state.vatCalculationKind == kind,
                    action: {
                        state.vatCalculationKind = kind
                        state.activeEntryField = .amount
                    }
                )
            }
        case .independent:
            profileRows
            amountKindRows(selection: $state.amountKind, prefix: "Montant saisi")
            SettingToggleRow(
                title: "Franchise en base",
                subtitle: "TVA non facturée",
                isOn: state.franchiseInBase,
                action: { state.toggleFranchiseInBase() }
            )
            SettingToggleRow(
                title: "Versement libératoire",
                subtitle: "Option soumise à conditions",
                isOn: state.vflEnabled,
                action: { state.vflEnabled.toggle() }
            )
            SettingToggleRow(
                title: "Inclure la CFP",
                subtitle: "Dans le montant à garder prudemment",
                isOn: state.includeCFPReserve,
                action: { state.includeCFPReserve.toggle() }
            )
        case .netGoal:
            profileRows
            SettingToggleRow(
                title: "Franchise en base",
                subtitle: "TVA non facturée",
                isOn: state.franchiseInBase,
                action: { state.toggleFranchiseInBase() }
            )
            SettingToggleRow(
                title: "Versement libératoire",
                subtitle: "Inclus dans l'objectif net",
                isOn: state.vflEnabled,
                action: { state.vflEnabled.toggle() }
            )
            SettingToggleRow(
                title: "Inclure la CFP",
                subtitle: "Majore le montant HT à facturer",
                isOn: state.includeCFPInNetGoal,
                action: { state.includeCFPInNetGoal.toggle() }
            )
        case .margin:
            ForEach(MarginInputField.allCases) { field in
                SettingOptionRow(
                    title: field.rawValue,
                    subtitle: "Champ modifié par le clavier",
                    isSelected: state.activeMarginField == field,
                    action: { state.selectMarginField(field) }
                )
            }
            amountKindRows(selection: $state.purchaseKind, prefix: "Achat")
            amountKindRows(selection: $state.saleKind, prefix: "Vente")
            SettingToggleRow(
                title: "Franchise en base",
                subtitle: "TVA collectée et déductible à zéro",
                isOn: state.franchiseInBase,
                action: { state.toggleFranchiseInBase() }
            )
            SettingToggleRow(
                title: "TVA déductible",
                subtitle: "Déduire la TVA sur l'achat",
                isOn: state.vatDeductibleOnPurchase,
                action: { state.vatDeductibleOnPurchase.toggle() }
            )
        }
    }

    private var profileRows: some View {
        ForEach(ruleSet.microProfiles) { profile in
            SettingOptionRow(
                title: profile.label,
                subtitle: "Profil micro V1",
                isSelected: state.selectedProfileId == profile.id,
                action: { state.selectedProfileId = profile.id }
            )
        }
    }

    private func amountKindRows(
        selection: Binding<AmountKind>,
        prefix: String
    ) -> some View {
        Group {
            SettingOptionRow(
                title: "\(prefix) HT",
                subtitle: "Hors taxe",
                isSelected: selection.wrappedValue == .ht,
                action: { selection.wrappedValue = .ht }
            )
            SettingOptionRow(
                title: "\(prefix) TTC",
                subtitle: "Toutes taxes comprises",
                isSelected: selection.wrappedValue == .ttc,
                action: { selection.wrappedValue = .ttc }
            )
        }
    }
}

private struct SettingOptionRow: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.body.weight(.semibold))
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.orange : Color.secondary)
                    .font(.system(size: 22, weight: .semibold))
            }
            .frame(minHeight: 48)
        }
        .buttonStyle(.plain)
    }
}

private struct SettingToggleRow: View {
    let title: String
    let subtitle: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.body.weight(.semibold))
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isOn ? Color.orange : Color.secondary)
                    .font(.system(size: 22, weight: .semibold))
            }
            .frame(minHeight: 48)
        }
        .buttonStyle(.plain)
    }
}

private struct NumericKeypad: View {
    private let rows = [
        ["C", "±", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "−"],
        ["1", "2", "3", "+"],
        ["0", ",", "⌫", "="]
    ]

    let keyHeight: CGFloat
    let onKey: (String) -> Void

    var body: some View {
        VStack(spacing: 8) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { key in
                        Button {
                            onKey(key)
                        } label: {
                            Text(key)
                                .font(.system(size: 27, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .frame(height: keyHeight)
                                .background(background(for: key))
                                .foregroundStyle(foreground(for: key))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Touche \(key)")
                    }
                }
            }
        }
    }

    private func background(for key: String) -> Color {
        if ["=", "+", "−", "×", "÷"].contains(key) {
            return .orange
        }

        if ["C", "±", "%", "⌫"].contains(key) {
            return Color.white.opacity(0.28)
        }

        return Color.white.opacity(0.14)
    }

    private func foreground(for key: String) -> Color {
        ["=", "+", "−", "×", "÷"].contains(key) ? .black : .white
    }
}

private struct CalculationDetailView: View {
    let result: CalculationResult
    let ruleSet: TaxRuleSet

    var body: some View {
        NavigationStack {
            List {
                Section("Résultat") {
                    HStack {
                        Text(result.mainLabel)
                        Spacer()
                        Text(result.mainAmount.currencyText)
                            .fontWeight(.semibold)
                    }
                }

                Section("Détail") {
                    ForEach(result.lines) { line in
                        HStack(alignment: .firstTextBaseline) {
                            Text(line.label)
                            Spacer(minLength: 16)
                            Text(line.displayValue)
                                .fontWeight(line.isEmphasized ? .semibold : .regular)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }

                Section("Formule utilisée") {
                    Text(result.formula)
                    Text("Barèmes vérifiés le 14/05/2026")
                        .fontWeight(.semibold)
                    Text("Source interne : \(result.sourceRuleSetId)")
                        .foregroundStyle(.secondary)
                }

                Section("Prudence") {
                    ForEach(result.warnings) { warning in
                        Text(warning.message)
                    }
                }

                Section("Sources") {
                    ForEach(ruleSet.sources, id: \.self) { source in
                        Text(source)
                    }
                }
            }
            .navigationTitle("Détail du calcul")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct HistoryView: View {
    let entries: [CalculationHistoryEntry]
    let onClear: () -> Void

    var body: some View {
        NavigationStack {
            List {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "Aucun historique",
                        systemImage: "clock",
                        description: Text("Les calculs restent stockés localement sur cet iPhone.")
                    )
                } else {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(entry.mode.rawValue)
                                    .font(.headline)
                                Spacer()
                                Text(entry.mainAmount.currencyText)
                                    .fontWeight(.semibold)
                            }

                            Text(entry.mainLabel)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(entry.formula)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Historique")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Effacer", action: onClear)
                        .disabled(entries.isEmpty)
                }
            }
        }
    }
}

#Preview {
    CalculatorShellView()
        .environment(EntitlementStore(service: PreviewStoreKitService()))
}
