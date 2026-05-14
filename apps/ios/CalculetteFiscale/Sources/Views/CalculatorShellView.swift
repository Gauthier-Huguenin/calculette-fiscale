import SwiftUI
import UIKit

struct CalculatorShellView: View {
    private let ruleSet = TaxRuleSet.french2026

    @State private var state = CalculatorViewState()
    @State private var isShowingDetails = false
    @State private var isShowingHistory = false
    @State private var copyFeedback = false

    private var result: CalculationResult {
        state.currentResult(ruleSet: ruleSet)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 12) {
                HeaderBar(
                    onHistory: { isShowingHistory = true },
                    historyCount: state.history.count
                )

                ModeSelector(state: $state)

                Spacer(minLength: 6)

                ResultPanel(
                    result: result,
                    activeFieldLabel: state.activeFieldLabel,
                    activeText: state.activeText,
                    activeVATRate: state.activeVATRate(ruleSet: ruleSet),
                    isCustomRateActive: state.activeEntryField == .customVATRate,
                    copyFeedback: copyFeedback,
                    onCopy: copyResult
                )

                ContextControls(
                    state: $state,
                    ruleSet: ruleSet,
                    onDetails: { isShowingDetails = true }
                )

                NumericKeypad { key in
                    handleKey(key)
                }

                PrudenceFooter()
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 8)
        }
        .preferredColorScheme(.dark)
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
    }

    private func handleKey(_ key: String) {
        state.tapKey(key)

        if key == "=" {
            state.addHistoryEntry(result: result)
        }
    }

    private func copyResult() {
        UIPasteboard.general.string = result.copyText
        state.addHistoryEntry(result: result)
        copyFeedback = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            copyFeedback = false
        }
    }
}

private struct HeaderBar: View {
    let onHistory: () -> Void
    let historyCount: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Calculette Fiscale")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)

                Text("Barèmes vérifiés le 14/05/2026")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.58))
            }

            Spacer()

            Button(action: onHistory) {
                Label("\(historyCount)", systemImage: "clock.arrow.circlepath")
                    .labelStyle(.titleAndIcon)
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
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

    var body: some View {
        HStack(spacing: 6) {
            ForEach(CalculationMode.allCases) { mode in
                Button {
                    state.selectMode(mode)
                } label: {
                    Text(mode.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(state.selectedMode == mode ? Color.white : Color.white.opacity(0.12))
                        .foregroundStyle(state.selectedMode == mode ? Color.black : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Mode \(mode.rawValue)")
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
        VStack(alignment: .trailing, spacing: 8) {
            HStack {
                Text(activeFieldLabel)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(isCustomRateActive ? Color.orange : Color.white.opacity(0.62))

                Spacer()

                Text("TVA \(activeVATRate.percentText)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.orange)
            }

            Text(isCustomRateActive ? "\(activeText) %" : activeText)
                .font(.system(size: 44, weight: .light, design: .rounded))
                .minimumScaleFactor(0.38)
                .lineLimit(1)
                .foregroundStyle(.white.opacity(0.72))

            Button(action: onCopy) {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(result.mainLabel)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.66))

                    Text(result.mainAmount.currencyText)
                        .font(.system(size: 48, weight: .light, design: .rounded))
                        .minimumScaleFactor(0.42)
                        .lineLimit(1)
                        .foregroundStyle(.white)

                    Label(copyFeedback ? "Copié" : "Toucher pour copier", systemImage: "doc.on.doc")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(copyFeedback ? Color.green : Color.white.opacity(0.48))
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Copier le résultat")
        }
    }
}

private struct ContextControls: View {
    @Binding var state: CalculatorViewState
    let ruleSet: TaxRuleSet
    let onDetails: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            RatePicker(state: $state, ruleSet: ruleSet)

            modeControls

            HStack(spacing: 8) {
                Button(action: onDetails) {
                    Label("Détail", systemImage: "list.bullet.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(Color.white.opacity(0.12))
                .foregroundStyle(.white)
                .clipShape(Capsule())

                ToggleChip(
                    title: "Franchise",
                    isOn: state.franchiseInBase,
                    action: { state.toggleFranchiseInBase() }
                )
            }
        }
    }

    @ViewBuilder
    private var modeControls: some View {
        switch state.selectedMode {
        case .vat:
            HorizontalChips {
                ForEach(VATCalculationKind.allCases) { kind in
                    ToggleChip(
                        title: kind.rawValue,
                        isOn: state.vatCalculationKind == kind,
                        action: {
                            state.vatCalculationKind = kind
                            state.activeEntryField = .amount
                        }
                    )
                }
            }
        case .independent:
            VStack(spacing: 8) {
                ProfilePicker(state: $state, ruleSet: ruleSet)
                HorizontalChips {
                    AmountKindChip(title: "Saisie HT", kind: .ht, selection: $state.amountKind)
                    AmountKindChip(title: "Saisie TTC", kind: .ttc, selection: $state.amountKind)
                    ToggleChip(title: "Versement libératoire", isOn: state.vflEnabled) {
                        state.vflEnabled.toggle()
                    }
                }
            }
        case .netGoal:
            VStack(spacing: 8) {
                ProfilePicker(state: $state, ruleSet: ruleSet)
                HorizontalChips {
                    ToggleChip(title: "Versement libératoire", isOn: state.vflEnabled) {
                        state.vflEnabled.toggle()
                    }
                    ToggleChip(title: "Inclure CFP", isOn: state.includeCFPInNetGoal) {
                        state.includeCFPInNetGoal.toggle()
                    }
                }
            }
        case .margin:
            VStack(spacing: 8) {
                HorizontalChips {
                    ForEach(MarginInputField.allCases) { field in
                        ToggleChip(
                            title: field.rawValue,
                            isOn: state.activeMarginField == field,
                            action: { state.selectMarginField(field) }
                        )
                    }
                    ToggleChip(title: "TVA déductible", isOn: state.vatDeductibleOnPurchase) {
                        state.vatDeductibleOnPurchase.toggle()
                    }
                }

                HorizontalChips {
                    if state.activeMarginField == .purchase {
                        AmountKindChip(title: "Achat HT", kind: .ht, selection: $state.purchaseKind)
                        AmountKindChip(title: "Achat TTC", kind: .ttc, selection: $state.purchaseKind)
                    } else {
                        AmountKindChip(title: "Vente HT", kind: .ht, selection: $state.saleKind)
                        AmountKindChip(title: "Vente TTC", kind: .ttc, selection: $state.saleKind)
                    }
                }
            }
        }
    }
}

private struct RatePicker: View {
    @Binding var state: CalculatorViewState
    let ruleSet: TaxRuleSet

    var body: some View {
        HorizontalChips {
            ForEach(ruleSet.vatRates) { rate in
                ToggleChip(
                    title: rate.label,
                    isOn: !state.usesCustomVATRate && state.selectedVATRateId == rate.id,
                    action: { state.selectVATRate(id: rate.id) }
                )
            }

            ToggleChip(
                title: "Perso \(state.customVATRateText) %",
                isOn: state.usesCustomVATRate,
                action: { state.selectCustomVATRate() }
            )
        }
    }
}

private struct ProfilePicker: View {
    @Binding var state: CalculatorViewState
    let ruleSet: TaxRuleSet

    var body: some View {
        HorizontalChips {
            ForEach(ruleSet.microProfiles) { profile in
                ToggleChip(
                    title: profile.label,
                    isOn: state.selectedProfileId == profile.id,
                    action: { state.selectedProfileId = profile.id }
                )
            }
        }
    }
}

private struct AmountKindChip: View {
    let title: String
    let kind: AmountKind
    @Binding var selection: AmountKind

    var body: some View {
        ToggleChip(
            title: title,
            isOn: selection == kind,
            action: { selection = kind }
        )
    }
}

private struct HorizontalChips<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                content
            }
            .padding(.horizontal, 1)
        }
    }
}

private struct ToggleChip: View {
    let title: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(isOn ? Color.orange : Color.white.opacity(0.12))
                .foregroundStyle(isOn ? Color.black : Color.white)
                .clipShape(Capsule())
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
                                .font(.system(size: 25, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(background(for: key))
                                .foregroundStyle(foreground(for: key))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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

private struct PrudenceFooter: View {
    var body: some View {
        Text("Estimation indicative. Cette calculette ne remplace pas une déclaration officielle ni un conseil adapté à votre situation.")
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.white.opacity(0.46))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, 6)
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
}
