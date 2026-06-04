import SwiftUI
import UIKit

struct CalculatorShellView: View {
    @Environment(EntitlementStore.self) private var entitlementStore

    private let ruleSet = TaxRuleSet.french2026
    private let screenshotScenario: ScreenshotScenario?

    @State private var state: CalculatorViewState
    @State private var isShowingDetails: Bool
    @State private var isShowingHistory: Bool
    @State private var isShowingPaywall = false
    @State private var isShowingSettings: Bool
    @State private var activePicker: CalculatorPicker?
    @State private var defaultSettings: DefaultCalculatorSettings
    @State private var copyFeedback = false

    init(screenshotScenario: ScreenshotScenario? = nil) {
        self.screenshotScenario = screenshotScenario
        let defaults = CalculatorDefaultsStore.load()
        _state = State(initialValue: screenshotScenario?.state ?? CalculatorViewState(defaults: defaults))
        _isShowingDetails = State(initialValue: screenshotScenario?.presentedSheet == .details)
        _isShowingHistory = State(initialValue: screenshotScenario?.presentedSheet == .history)
        _isShowingSettings = State(initialValue: screenshotScenario?.presentedSheet == .settings)
        _defaultSettings = State(initialValue: defaults)
    }

    var body: some View {
        let result = state.currentResult(ruleSet: ruleSet)

        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        HeaderBar(
                            onHistory: openHistory,
                            isPro: entitlementStore.isPro,
                            historyCount: state.history.count
                        )

                        ModeSelector(state: $state)

                        CalculatorWorkspaceView(
                            state: $state,
                            result: result,
                            ruleSet: ruleSet,
                            copyFeedback: copyFeedback,
                            onPicker: { activePicker = $0 },
                            onCopy: { copyResult(result) },
                            onDetails: openDetails
                        )

                        ActionBar(
                            isPro: entitlementStore.isPro,
                            onSettings: { isShowingSettings = true },
                            onDetails: openDetails
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: entitlementStore.isPro) { _, isPro in
            if isPro {
                isShowingPaywall = false
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            DefaultSettingsView(
                settings: $defaultSettings,
                ruleSet: ruleSet,
                onSave: { settings in
                    CalculatorDefaultsStore.save(settings)
                }
            )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $activePicker) { picker in
            CalculatorPickerSheet(
                picker: picker,
                state: $state,
                ruleSet: ruleSet
            )
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

        if key == "=" && entitlementStore.isPro && state.arithmeticError == nil {
            state.addHistoryEntry(result: state.currentResult(ruleSet: ruleSet))
        }
    }

    private func copyResult(_ result: CalculationResult) {
        UIPasteboard.general.string = DecisionSummary.copyText(
            for: state,
            result: result,
            ruleSet: ruleSet
        )

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

enum ScreenshotPresentedSheet {
    case details
    case history
    case settings
}

enum ScreenshotScenario: String {
    case vatInvoice = "01-tva-facture"
    case netPro = "02-net-pro"
    case netGoal = "03-objectif-net"
    case margin = "04-marge"
    case localHistory = "05-historique-local"
    case customization = "06-personnalisation"

    static var current: ScreenshotScenario? {
        #if DEBUG
        let scenario = ProcessInfo.processInfo.environment["CALCULETTE_SCREENSHOT_SCENARIO"]
        return scenario.flatMap(ScreenshotScenario.init(rawValue:))
        #else
        return nil
        #endif
    }

    var isPro: Bool {
        true
    }

    var presentedSheet: ScreenshotPresentedSheet? {
        switch self {
        case .localHistory:
            return .history
        case .customization:
            return .settings
        case .vatInvoice, .netPro, .netGoal, .margin:
            return nil
        }
    }

    var state: CalculatorViewState {
        var state = CalculatorViewState()
        state.history = Self.historyEntries

        switch self {
        case .vatInvoice:
            state.selectedMode = .vat
            state.vatCalculationKind = .htToTTC
            state.amountText = "1250"
            state.selectedVATRateId = "vat_standard"
        case .netPro:
            state.selectedMode = .independent
            state.amountText = "2400"
            state.amountKind = .ttc
            state.selectedProfileId = .microBNCServiceGeneral
            state.includeCFPReserve = true
        case .netGoal:
            state.selectedMode = .netGoal
            state.amountText = "2500"
            state.selectedProfileId = .microBICService
            state.vflEnabled = true
            state.includeCFPInNetGoal = true
        case .margin:
            state.selectedMode = .margin
            state.purchaseText = "72"
            state.saleText = "120"
            state.purchaseKind = .ttc
            state.saleKind = .ttc
            state.activeMarginField = .sale
            state.activeEntryField = .marginSale
        case .localHistory:
            state.selectedMode = .independent
            state.amountText = "2400"
            state.amountKind = .ttc
            state.selectedProfileId = .microBNCServiceGeneral
            state.includeCFPReserve = true
        case .customization:
            state.selectedMode = .independent
            state.amountText = "1800"
            state.selectedProfileId = .microBICService
            state.selectedVATRateId = "vat_intermediate"
            state.vflEnabled = true
            state.includeCFPReserve = true
        }

        return state
    }

    private static var historyEntries: [CalculationHistoryEntry] {
        [
            entry(
                id: "9E5D6859-4D8F-48A1-AD0B-F7F69F93C001",
                daysAgo: 0
            ) { state in
                state.selectedMode = .independent
                state.amountText = "2400"
                state.amountKind = .ttc
                state.selectedProfileId = .microBNCServiceGeneral
            },
            entry(
                id: "9E5D6859-4D8F-48A1-AD0B-F7F69F93C002",
                daysAgo: 1
            ) { state in
                state.selectedMode = .netGoal
                state.amountText = "2500"
                state.selectedProfileId = .microBICService
                state.vflEnabled = true
                state.includeCFPInNetGoal = true
            },
            entry(
                id: "9E5D6859-4D8F-48A1-AD0B-F7F69F93C003",
                daysAgo: 2
            ) { state in
                state.selectedMode = .margin
                state.purchaseText = "72"
                state.saleText = "120"
                state.purchaseKind = .ttc
                state.saleKind = .ttc
            }
        ]
    }

    private static func entry(
        id: String,
        daysAgo: Int,
        configure: (inout CalculatorViewState) -> Void
    ) -> CalculationHistoryEntry {
        var state = CalculatorViewState()
        configure(&state)

        let date = Calendar(identifier: .gregorian).date(
            byAdding: .day,
            value: -daysAgo,
            to: DateComponents(
                calendar: Calendar(identifier: .gregorian),
                year: 2026,
                month: 5,
                day: 21,
                hour: 9
            ).date ?? Date()
        ) ?? Date()

        return CalculationHistoryEntry(
            id: UUID(uuidString: id) ?? UUID(),
            date: date,
            mode: state.selectedMode,
            result: state.currentResult(ruleSet: .french2026)
        )
    }
}

private struct HeaderBar: View {
    let onHistory: () -> Void
    let isPro: Bool
    let historyCount: Int

    private var historyButtonTitle: String {
        isPro ? "\(historyCount)" : "Pro"
    }

    private var historyButtonImage: String {
        isPro ? "clock.arrow.circlepath" : "lock.fill"
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Calculette Fiscale")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text("TVA, net et marge")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.58))
                    .lineLimit(1)
            }

            Spacer()

            Button(action: onHistory) {
                Label(historyButtonTitle, systemImage: historyButtonImage)
                    .labelStyle(.titleAndIcon)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)
                    .frame(minWidth: 58, minHeight: 44)
                    .padding(.horizontal, 10)
                    .background(Color.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .accessibilityLabel(isPro ? "Historique" : "Version Pro")
        }
        .frame(minHeight: 58)
    }
}

private struct ModeSelector: View {
    @Binding var state: CalculatorViewState

    var body: some View {
        HStack(spacing: 8) {
            ForEach(CalculationMode.allCases) { mode in
                ModeButton(
                    title: mode.intentTitle,
                    isSelected: state.selectedMode == mode,
                    action: { state.selectMode(mode) }
                )
            }
        }
    }
}

private struct ModeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            .frame(maxWidth: .infinity, minHeight: 52)
            .padding(.horizontal, 6)
            .background(isSelected ? Color.white : Color.white.opacity(0.11))
            .foregroundStyle(isSelected ? Color.black : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Calculette \(title)")
    }
}

private enum CalculatorPicker: String, Identifiable {
    case vatRate
    case profile
    case amountKind
    case purchaseKind
    case saleKind
    case vatApplicability
    case vfl
    case cfpReserve
    case cfpNetGoal
    case vatDeductible

    var id: String { rawValue }

    var title: String {
        switch self {
        case .vatRate:
            return "Taux de TVA"
        case .profile:
            return "Profil fiscal"
        case .amountKind:
            return "Montant saisi"
        case .purchaseKind:
            return "Prix d'achat"
        case .saleKind:
            return "Prix de vente"
        case .vatApplicability:
            return "TVA"
        case .vfl:
            return "Versement libératoire"
        case .cfpReserve:
            return "CFP"
        case .cfpNetGoal:
            return "CFP objectif net"
        case .vatDeductible:
            return "TVA sur achat"
        }
    }
}

private struct CalculatorWorkspaceView: View {
    @Binding var state: CalculatorViewState
    let result: CalculationResult
    let ruleSet: TaxRuleSet
    let copyFeedback: Bool
    let onPicker: (CalculatorPicker) -> Void
    let onCopy: () -> Void
    let onDetails: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            switch state.selectedMode {
            case .independent:
                ResteNetCalculatorView(
                    state: $state,
                    result: result,
                    ruleSet: ruleSet,
                    copyFeedback: copyFeedback,
                    onPicker: onPicker,
                    onCopy: onCopy,
                    onDetails: onDetails
                )
            case .netGoal:
                NetGoalCalculatorView(
                    state: $state,
                    result: result,
                    ruleSet: ruleSet,
                    copyFeedback: copyFeedback,
                    onPicker: onPicker,
                    onCopy: onCopy,
                    onDetails: onDetails
                )
            case .vat:
                VATCalculatorView(
                    state: $state,
                    result: result,
                    ruleSet: ruleSet,
                    copyFeedback: copyFeedback,
                    onPicker: onPicker,
                    onCopy: onCopy,
                    onDetails: onDetails
                )
            case .margin:
                MarginCalculatorView(
                    state: $state,
                    result: result,
                    ruleSet: ruleSet,
                    copyFeedback: copyFeedback,
                    onPicker: onPicker,
                    onCopy: onCopy,
                    onDetails: onDetails
                )
            }
        }
    }
}

private struct ResteNetCalculatorView: View {
    @Binding var state: CalculatorViewState
    let result: CalculationResult
    let ruleSet: TaxRuleSet
    let copyFeedback: Bool
    let onPicker: (CalculatorPicker) -> Void
    let onCopy: () -> Void
    let onDetails: () -> Void

    private var htAmount: Decimal {
        amount("ca_ht", in: result)
    }

    private var vatAmount: Decimal {
        amount("vat", in: result)
    }

    private var ttcAmount: Decimal {
        state.vatApplicable ? (htAmount + vatAmount).currencyRounded : htAmount
    }

    var body: some View {
        VStack(spacing: 14) {
            AmountInputPanel(
                title: "Montant facturé ou encaissé",
                text: $state.amountText,
                trailingTitle: state.amountKind.rawValue,
                trailingAction: { onPicker(.amountKind) }
            )

            ChipGrid {
                EditableChip(title: state.amountKind.rawValue, systemImage: "arrow.left.arrow.right", action: { onPicker(.amountKind) })
                EditableChip(title: vatChipTitle, systemImage: "percent", action: { onPicker(.vatApplicability) })
                EditableChip(title: rateChipTitle(state: state, ruleSet: ruleSet), systemImage: "tag", action: { onPicker(.vatRate) })
                EditableChip(title: profileShortLabel(state.selectedProfileId), systemImage: "person.crop.circle", action: { onPicker(.profile) })
                EditableChip(title: state.vflEnabled ? "VFL activé" : "VFL désactivé", systemImage: "checklist", action: { onPicker(.vfl) })
                EditableChip(title: state.includeCFPReserve ? "CFP incluse" : "CFP séparée", systemImage: "shield", action: { onPicker(.cfpReserve) })
            }

            MainResultCard(
                title: "Il te reste environ",
                amount: result.mainAmount.currencyText,
                subtitle: "Estimation après cotisations",
                copyFeedback: copyFeedback,
                onCopy: onCopy,
                onDetails: onDetails
            )

            MetricList(rows: [
                MetricRowData(label: "Montant HT", value: htAmount.currencyText),
                MetricRowData(label: "Montant TTC", value: ttcAmount.currencyText),
                MetricRowData(label: "TVA à mettre de côté", value: state.vatApplicable ? vatAmount.currencyText : "Non facturée"),
                MetricRowData(label: "Cotisations estimées", value: value("social", in: result)),
                MetricRowData(label: "Net estimé", value: result.mainAmount.currencyText, isEmphasized: true)
            ])
        }
    }

    private var vatChipTitle: String {
        state.franchiseInBase ? "Franchise TVA" : "TVA facturée"
    }
}

private struct NetGoalCalculatorView: View {
    @Binding var state: CalculatorViewState
    let result: CalculationResult
    let ruleSet: TaxRuleSet
    let copyFeedback: Bool
    let onPicker: (CalculatorPicker) -> Void
    let onCopy: () -> Void
    let onDetails: () -> Void

    private var requiredTTC: String {
        state.vatApplicable ? value("required_ttc", in: result) : "Sans TVA"
    }

    var body: some View {
        VStack(spacing: 14) {
            AmountInputPanel(
                title: "Objectif net à garder",
                text: $state.amountText,
                trailingTitle: "Net",
                trailingAction: nil
            )

            ChipGrid {
                EditableChip(title: profileShortLabel(state.selectedProfileId), systemImage: "person.crop.circle", action: { onPicker(.profile) })
                EditableChip(title: state.franchiseInBase ? "Franchise TVA" : "TVA facturée", systemImage: "percent", action: { onPicker(.vatApplicability) })
                EditableChip(title: rateChipTitle(state: state, ruleSet: ruleSet), systemImage: "tag", action: { onPicker(.vatRate) })
                EditableChip(title: state.vflEnabled ? "VFL activé" : "VFL désactivé", systemImage: "checklist", action: { onPicker(.vfl) })
                EditableChip(title: state.includeCFPInNetGoal ? "CFP incluse" : "CFP séparée", systemImage: "shield", action: { onPicker(.cfpNetGoal) })
            }

            MainResultCard(
                title: "Tu dois facturer environ",
                amount: "\(result.mainAmount.currencyText) HT",
                subtitle: state.vatApplicable ? "soit \(requiredTTC) TTC" : "franchise en base de TVA",
                copyFeedback: copyFeedback,
                onCopy: onCopy,
                onDetails: onDetails
            )

            MetricList(rows: [
                MetricRowData(label: "Objectif net", value: value("target", in: result)),
                MetricRowData(label: "Montant HT à facturer", value: value("required_ht", in: result), isEmphasized: true),
                MetricRowData(label: "Montant TTC indicatif", value: requiredTTC),
                MetricRowData(label: "TVA collectée", value: state.vatApplicable ? value("required_vat", in: result) : "Non facturée"),
                MetricRowData(label: "Cotisations estimées", value: value("social", in: result))
            ])
        }
    }
}

private struct VATCalculatorView: View {
    @Binding var state: CalculatorViewState
    let result: CalculationResult
    let ruleSet: TaxRuleSet
    let copyFeedback: Bool
    let onPicker: (CalculatorPicker) -> Void
    let onCopy: () -> Void
    let onDetails: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            AmountInputPanel(
                title: inputTitle,
                text: $state.amountText,
                trailingTitle: rateChipTitle(state: state, ruleSet: ruleSet),
                trailingAction: { onPicker(.vatRate) }
            )

            HStack(spacing: 8) {
                ForEach(VATCalculationKind.allCases) { kind in
                    SegmentButton(
                        title: kind.shortTitle,
                        isSelected: state.vatCalculationKind == kind,
                        compactHeight: false,
                        action: {
                            state.vatCalculationKind = kind
                            state.activeEntryField = .amount
                        }
                    )
                }
            }

            ChipGrid {
                EditableChip(title: rateChipTitle(state: state, ruleSet: ruleSet), systemImage: "percent", action: { onPicker(.vatRate) })
            }

            MainResultCard(
                title: resultTitle,
                amount: result.mainAmount.currencyText,
                subtitle: "Taux utilisé : \(value("rate", in: result))",
                copyFeedback: copyFeedback,
                onCopy: onCopy,
                onDetails: onDetails
            )

            MetricList(rows: [
                MetricRowData(label: "Montant HT", value: value("ht", in: result)),
                MetricRowData(label: "Montant TTC", value: value("ttc", in: result)),
                MetricRowData(label: "TVA à mettre de côté", value: value("vat", in: result), isEmphasized: true)
            ])
        }
    }

    private var inputTitle: String {
        switch state.vatCalculationKind {
        case .htToTTC:
            return "Montant HT"
        case .ttcToHT:
            return "Montant TTC"
        case .vatOnly:
            return "Base HT"
        }
    }

    private var resultTitle: String {
        switch state.vatCalculationKind {
        case .htToTTC:
            return "Montant TTC"
        case .ttcToHT:
            return "Montant HT"
        case .vatOnly:
            return "TVA seule"
        }
    }
}

private struct MarginCalculatorView: View {
    @Binding var state: CalculatorViewState
    let result: CalculationResult
    let ruleSet: TaxRuleSet
    let copyFeedback: Bool
    let onPicker: (CalculatorPicker) -> Void
    let onCopy: () -> Void
    let onDetails: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            AmountInputPanel(
                title: "Prix d'achat",
                text: $state.purchaseText,
                trailingTitle: state.purchaseKind.rawValue,
                trailingAction: { onPicker(.purchaseKind) }
            )

            AmountInputPanel(
                title: "Prix de vente",
                text: $state.saleText,
                trailingTitle: state.saleKind.rawValue,
                trailingAction: { onPicker(.saleKind) }
            )

            ChipGrid {
                EditableChip(title: "Achat \(state.purchaseKind.rawValue)", systemImage: "cart", action: { onPicker(.purchaseKind) })
                EditableChip(title: "Vente \(state.saleKind.rawValue)", systemImage: "tag", action: { onPicker(.saleKind) })
                EditableChip(title: state.franchiseInBase ? "Franchise TVA" : "TVA facturée", systemImage: "percent", action: { onPicker(.vatApplicability) })
                EditableChip(title: rateChipTitle(state: state, ruleSet: ruleSet), systemImage: "number", action: { onPicker(.vatRate) })
                EditableChip(title: state.vatDeductibleOnPurchase ? "TVA achat déductible" : "TVA achat non déduite", systemImage: "minus.circle", action: { onPicker(.vatDeductible) })
            }

            MainResultCard(
                title: "Marge brute HT",
                amount: result.mainAmount.currencyText,
                subtitle: "Taux de marque : \(value("mark_rate", in: result))",
                copyFeedback: copyFeedback,
                onCopy: onCopy,
                onDetails: onDetails
            )

            MetricList(rows: [
                MetricRowData(label: "Marge brute HT", value: value("gross_margin", in: result), isEmphasized: true),
                MetricRowData(label: "Taux de marge", value: value("margin_rate", in: result)),
                MetricRowData(label: "Taux de marque", value: value("mark_rate", in: result)),
                MetricRowData(label: "TVA collectée", value: state.vatApplicable ? value("vat_collected", in: result) : "Non facturée"),
                MetricRowData(label: "TVA nette", value: value("net_vat", in: result))
            ])
        }
    }
}

private struct AmountInputPanel: View {
    let title: String
    @Binding var text: String
    let trailingTitle: String
    let trailingAction: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.70))

                Spacer()

                if let trailingAction {
                    Button(action: trailingAction) {
                        Text(trailingTitle)
                            .font(.system(size: 14, weight: .semibold))
                            .lineLimit(1)
                            .padding(.horizontal, 10)
                            .frame(minHeight: 32)
                            .background(Color.orange.opacity(0.20))
                            .foregroundStyle(.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                } else {
                    Text(trailingTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.54))
                }
            }

            TextField("0", text: $text)
                .keyboardType(.decimalPad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: 44, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.45)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }
}

private struct ChipGrid<Content: View>: View {
    let content: Content

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            content
        }
    }
}

private struct EditableChip: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .frame(maxWidth: .infinity, minHeight: 38, alignment: .leading)
                .padding(.horizontal, 10)
                .background(Color.white.opacity(0.11))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct MainResultCard: View {
    let title: String
    let amount: String
    let subtitle: String
    let copyFeedback: Bool
    let onCopy: () -> Void
    let onDetails: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text(amount)
                    .font(.system(size: 54, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.34)

                Text(subtitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.64))
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 10) {
                ResultActionButton(
                    title: copyFeedback ? "Copié" : "Copier le résumé",
                    systemImage: copyFeedback ? "checkmark.circle.fill" : "doc.on.doc",
                    action: onCopy
                )

                ResultActionButton(
                    title: "Voir le détail",
                    systemImage: "list.bullet.rectangle",
                    action: onDetails
                )
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

private struct ResultActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(maxWidth: .infinity, minHeight: 42)
                .background(Color.white.opacity(0.12))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct MetricRowData: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    var isEmphasized = false
}

private struct MetricList: View {
    let rows: [MetricRowData]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(rows) { row in
                HStack(alignment: .firstTextBaseline, spacing: 14) {
                    Text(row.label)
                        .font(.system(size: 15, weight: row.isEmphasized ? .semibold : .medium))
                        .foregroundStyle(.white.opacity(row.isEmphasized ? 0.92 : 0.64))

                    Spacer(minLength: 16)

                    Text(row.value)
                        .font(.system(size: 16, weight: row.isEmphasized ? .semibold : .medium, design: .rounded))
                        .foregroundStyle(row.isEmphasized ? Color.orange : Color.white)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                        .minimumScaleFactor(0.74)
                }
                .padding(.vertical, 12)

                if row.id != rows.last?.id {
                    Divider().overlay(Color.white.opacity(0.10))
                }
            }
        }
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct CalculatorPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    let picker: CalculatorPicker
    @Binding var state: CalculatorViewState
    let ruleSet: TaxRuleSet

    var body: some View {
        NavigationStack {
            List {
                content
            }
            .navigationTitle(picker.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Terminé") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var content: some View {
        switch picker {
        case .vatRate:
            Section("Taux usuels") {
                ForEach(ruleSet.vatRates) { rate in
                    PickerOptionRow(
                        title: rate.label,
                        subtitle: "Taux français usuel",
                        isSelected: !state.usesCustomVATRate && state.selectedVATRateId == rate.id,
                        action: {
                            state.selectVATRate(id: rate.id)
                            dismiss()
                        }
                    )
                }
            }

            Section("Taux personnalisé") {
                TextField("20", text: $state.customVATRateText)
                    .keyboardType(.decimalPad)
                PickerOptionRow(
                    title: "\(state.customVATRateText) %",
                    subtitle: "Utiliser ce taux pour le calcul courant.",
                    isSelected: state.usesCustomVATRate,
                    action: {
                        state.usesCustomVATRate = true
                        state.activeEntryField = .amount
                        dismiss()
                    }
                )
            }
        case .profile:
            ForEach(ruleSet.microProfiles) { profile in
                PickerOptionRow(
                    title: profile.label,
                    subtitle: "Cotisations estimées : \(profile.socialContributionRate.percentText)",
                    isSelected: state.selectedProfileId == profile.id,
                    action: {
                        state.selectedProfileId = profile.id
                        dismiss()
                    }
                )
            }
        case .amountKind:
            amountKindRows(selection: $state.amountKind)
        case .purchaseKind:
            amountKindRows(selection: $state.purchaseKind)
        case .saleKind:
            amountKindRows(selection: $state.saleKind)
        case .vatApplicability:
            PickerOptionRow(
                title: "TVA facturée",
                subtitle: "Les montants HT, TTC et TVA sont calculés.",
                isSelected: !state.franchiseInBase,
                action: {
                    state.franchiseInBase = false
                    dismiss()
                }
            )
            PickerOptionRow(
                title: "Franchise en base",
                subtitle: "La TVA est neutralisée dans le calcul courant.",
                isSelected: state.franchiseInBase,
                action: {
                    state.franchiseInBase = true
                    dismiss()
                }
            )
        case .vfl:
            booleanRows(
                isOn: $state.vflEnabled,
                enabledTitle: "VFL activé",
                disabledTitle: "VFL désactivé",
                enabledSubtitle: "Ajoute le versement libératoire au calcul.",
                disabledSubtitle: "L'impôt sur le revenu reste hors calcul."
            )
        case .cfpReserve:
            booleanRows(
                isOn: $state.includeCFPReserve,
                enabledTitle: "CFP incluse",
                disabledTitle: "CFP séparée",
                enabledSubtitle: "Ajoute une réserve prudente pour la CFP.",
                disabledSubtitle: "Affiche la CFP sans la retirer du net."
            )
        case .cfpNetGoal:
            booleanRows(
                isOn: $state.includeCFPInNetGoal,
                enabledTitle: "CFP incluse",
                disabledTitle: "CFP séparée",
                enabledSubtitle: "Majore le HT à facturer pour couvrir la CFP.",
                disabledSubtitle: "Affiche la CFP sans majorer l'objectif."
            )
        case .vatDeductible:
            booleanRows(
                isOn: $state.vatDeductibleOnPurchase,
                enabledTitle: "TVA achat déductible",
                disabledTitle: "TVA achat non déduite",
                enabledSubtitle: "Déduit la TVA de l'achat dans la TVA nette.",
                disabledSubtitle: "La TVA collectée n'est pas compensée par l'achat."
            )
        }
    }

    private func amountKindRows(selection: Binding<AmountKind>) -> some View {
        Group {
            PickerOptionRow(
                title: "HT",
                subtitle: "Le montant est hors taxe.",
                isSelected: selection.wrappedValue == .ht,
                action: {
                    selection.wrappedValue = .ht
                    dismiss()
                }
            )
            PickerOptionRow(
                title: "TTC",
                subtitle: "Le montant inclut la TVA.",
                isSelected: selection.wrappedValue == .ttc,
                action: {
                    selection.wrappedValue = .ttc
                    dismiss()
                }
            )
        }
    }

    private func booleanRows(
        isOn: Binding<Bool>,
        enabledTitle: String,
        disabledTitle: String,
        enabledSubtitle: String,
        disabledSubtitle: String
    ) -> some View {
        Group {
            PickerOptionRow(
                title: enabledTitle,
                subtitle: enabledSubtitle,
                isSelected: isOn.wrappedValue,
                action: {
                    isOn.wrappedValue = true
                    dismiss()
                }
            )
            PickerOptionRow(
                title: disabledTitle,
                subtitle: disabledSubtitle,
                isSelected: !isOn.wrappedValue,
                action: {
                    isOn.wrappedValue = false
                    dismiss()
                }
            )
        }
    }
}

private struct PickerOptionRow: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.orange : Color.secondary)
                    .font(.system(size: 24, weight: .semibold))
            }
            .frame(minHeight: 54)
        }
        .buttonStyle(.plain)
    }
}

private struct DefaultSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var settings: DefaultCalculatorSettings
    let ruleSet: TaxRuleSet
    let onSave: (DefaultCalculatorSettings) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Valeurs par défaut") {
                    defaultAmountKindRows(selection: $settings.amountKind, prefix: "Reste net")
                    defaultAmountKindRows(selection: $settings.purchaseKind, prefix: "Achat marge")
                    defaultAmountKindRows(selection: $settings.saleKind, prefix: "Vente marge")
                }

                Section("TVA") {
                    ForEach(ruleSet.vatRates) { rate in
                        SettingOptionRow(
                            title: rate.label,
                            subtitle: "Taux utilisé par défaut.",
                            isSelected: !settings.usesCustomVATRate && settings.selectedVATRateId == rate.id,
                            action: {
                                settings.usesCustomVATRate = false
                                settings.selectedVATRateId = rate.id
                                onSave(settings)
                            }
                        )
                    }

                    TextField("Taux personnalisé", text: $settings.customVATRateText)
                        .keyboardType(.decimalPad)

                    SettingOptionRow(
                        title: "\(settings.customVATRateText) %",
                        subtitle: "Utiliser le taux personnalisé par défaut.",
                        isSelected: settings.usesCustomVATRate,
                        action: {
                            settings.usesCustomVATRate = true
                            onSave(settings)
                        }
                    )

                    SettingToggleRow(
                        title: "Franchise en base",
                        subtitle: "Neutralise la TVA par défaut hors calculette TVA.",
                        isOn: settings.franchiseInBase,
                        action: {
                            settings.franchiseInBase.toggle()
                            onSave(settings)
                        }
                    )
                }

                Section("Profil fiscal") {
                    ForEach(ruleSet.microProfiles) { profile in
                        SettingOptionRow(
                            title: profile.label,
                            subtitle: "Cotisations estimées : \(profile.socialContributionRate.percentText)",
                            isSelected: settings.selectedProfileId == profile.id,
                            action: {
                                settings.selectedProfileId = profile.id
                                onSave(settings)
                            }
                        )
                    }
                }

                Section("Options") {
                    SettingToggleRow(
                        title: "Versement libératoire",
                        subtitle: "Option activée par défaut pour les calculettes net.",
                        isOn: settings.vflEnabled,
                        action: {
                            settings.vflEnabled.toggle()
                            onSave(settings)
                        }
                    )
                    SettingToggleRow(
                        title: "CFP dans Reste net",
                        subtitle: "Ajoute une réserve CFP par défaut.",
                        isOn: settings.includeCFPReserve,
                        action: {
                            settings.includeCFPReserve.toggle()
                            onSave(settings)
                        }
                    )
                    SettingToggleRow(
                        title: "CFP dans Objectif net",
                        subtitle: "Majore le montant HT par défaut.",
                        isOn: settings.includeCFPInNetGoal,
                        action: {
                            settings.includeCFPInNetGoal.toggle()
                            onSave(settings)
                        }
                    )
                    SettingToggleRow(
                        title: "TVA achat déductible",
                        subtitle: "Déduit la TVA d'achat par défaut dans Marge.",
                        isOn: settings.vatDeductibleOnPurchase,
                        action: {
                            settings.vatDeductibleOnPurchase.toggle()
                            onSave(settings)
                        }
                    )
                }

                Section("Prudence") {
                    Text("Calculs indicatifs. Ils ne remplacent pas un conseil comptable ou fiscal adapté.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Réglages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Terminé") {
                        onSave(settings)
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func defaultAmountKindRows(
        selection: Binding<AmountKind>,
        prefix: String
    ) -> some View {
        Group {
            SettingOptionRow(
                title: "\(prefix) HT",
                subtitle: "Montant hors taxe par défaut.",
                isSelected: selection.wrappedValue == .ht,
                action: {
                    selection.wrappedValue = .ht
                    onSave(settings)
                }
            )
            SettingOptionRow(
                title: "\(prefix) TTC",
                subtitle: "Montant toutes taxes comprises par défaut.",
                isSelected: selection.wrappedValue == .ttc,
                action: {
                    selection.wrappedValue = .ttc
                    onSave(settings)
                }
            )
        }
    }
}

private func value(_ id: String, in result: CalculationResult) -> String {
    result.lines.first { $0.id == id }?.displayValue ?? "0,00 €"
}

private func amount(_ id: String, in result: CalculationResult) -> Decimal {
    result.lines.first { $0.id == id }?.amount ?? 0
}

private func rateChipTitle(state: CalculatorViewState, ruleSet: TaxRuleSet) -> String {
    state.usesCustomVATRate ? "TVA \(state.customVATRateText) %" : "TVA \(state.activeVATRate(ruleSet: ruleSet).percentText)"
}

private func profileShortLabel(_ profileId: TaxProfileID) -> String {
    switch profileId {
    case .microBICSale:
        return "Micro-BIC vente"
    case .microBICService:
        return "Micro-BIC presta"
    case .microBNCServiceGeneral:
        return "Micro-BNC"
    }
}

private struct ResultPanel: View {
    let state: CalculatorViewState
    let result: CalculationResult
    let ruleSet: TaxRuleSet
    let compactHeight: Bool
    let copyFeedback: Bool
    let onCopy: () -> Void

    private var isCustomRateActive: Bool {
        state.activeEntryField == .customVATRate
    }

    private var activeInput: String {
        isCustomRateActive ? "\(state.activeText) %" : state.activeText
    }

    private var resultLabel: String {
        switch result.mainLabel {
        case "TTC":
            return "Montant TTC"
        case "HT":
            return "Montant HT"
        default:
            return result.mainLabel
        }
    }

    private var summaryLines: [String] {
        DecisionSummary.lines(for: state, result: result, ruleSet: ruleSet)
    }

    var body: some View {
        Button(action: onCopy) {
            VStack(alignment: .leading, spacing: compactHeight ? 10 : 14) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(state.activeFieldLabel)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(isCustomRateActive ? Color.orange : Color.white.opacity(0.64))

                        Text(activeInput)
                            .font(.system(size: inputFontSize, weight: .regular, design: .rounded))
                            .foregroundStyle(.white.opacity(0.78))
                            .lineLimit(1)
                            .minimumScaleFactor(0.45)
                    }

                    Spacer(minLength: 12)

                    Text("TVA \(state.activeVATRate(ruleSet: ruleSet).percentText)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.orange)
                }

                Divider()
                    .overlay(Color.white.opacity(0.16))

                VStack(alignment: .leading, spacing: 5) {
                    Text(resultLabel)
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)

                    Text(result.mainAmount.currencyText)
                        .font(.system(size: resultAmountFontSize, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.34)

                    VStack(alignment: .leading, spacing: 3) {
                        ForEach(summaryLines, id: \.self) { line in
                            Text(line)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white.opacity(0.66))
                                .lineLimit(1)
                                .minimumScaleFactor(0.74)
                        }
                    }
                }

                Label(copyFeedback ? "Copié" : "Toucher pour copier", systemImage: copyFeedback ? "checkmark.circle.fill" : "doc.on.doc")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(copyFeedback ? Color.green : Color.white.opacity(0.52))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, compactHeight ? 18 : 22)
            .padding(.vertical, compactHeight ? 16 : 22)
            .frame(maxWidth: .infinity, minHeight: panelMinHeight, alignment: .leading)
            .background(Color.white.opacity(0.075))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Copier le résultat")
    }

    private var inputFontSize: CGFloat {
        return compactHeight ? 34 : 42
    }

    private var resultAmountFontSize: CGFloat {
        return compactHeight ? 56 : 68
    }

    private var panelMinHeight: CGFloat {
        return compactHeight ? 188 : 238
    }
}

private struct EssentialControls: View {
    @Binding var state: CalculatorViewState
    let compactHeight: Bool

    var body: some View {
        Group {
            switch state.selectedMode {
            case .vat:
                HStack(spacing: 8) {
                    ForEach(VATCalculationKind.allCases) { kind in
                        SegmentButton(
                            title: kind.rawValue,
                            isSelected: state.vatCalculationKind == kind,
                            compactHeight: compactHeight,
                            action: {
                                state.vatCalculationKind = kind
                                state.activeEntryField = .amount
                            }
                        )
                    }
                }
            case .independent:
                StatusStrip(text: "\(state.amountKind.rawValue) saisi. Ajustez profil, TVA et options dans Réglages.")
            case .netGoal:
                StatusStrip(text: "Objectif net saisi. Ajustez profil, TVA et CFP dans Réglages.")
            case .margin:
                HStack(spacing: 8) {
                    ForEach(MarginInputField.allCases) { field in
                        SegmentButton(
                            title: "Saisir \(field.rawValue.lowercased())",
                            isSelected: state.activeMarginField == field,
                            compactHeight: compactHeight,
                            action: { state.selectMarginField(field) }
                        )
                    }
                }
            }
        }
    }
}

private struct ActionBar: View {
    let isPro: Bool
    let onSettings: () -> Void
    let onDetails: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            ActionButton(
                title: "Réglages",
                systemImage: "slider.horizontal.3",
                action: onSettings
            )

            ActionButton(
                title: "Détail",
                systemImage: isPro ? "list.bullet.rectangle" : "lock.fill",
                action: onDetails
            )
        }
    }
}

private struct StatusStrip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white.opacity(0.76))
            .lineLimit(2)
            .minimumScaleFactor(0.82)
            .frame(maxWidth: .infinity, minHeight: 46, alignment: .leading)
            .padding(.horizontal, 14)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct ActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .labelStyle(.titleAndIcon)
                .font(.system(size: 16, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(maxWidth: .infinity, minHeight: 50)
                .padding(.horizontal, 12)
                .background(Color.white.opacity(0.12))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct SegmentButton: View {
    let title: String
    let isSelected: Bool
    let compactHeight: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: compactHeight ? 13 : 15, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.70)
                .frame(maxWidth: .infinity, minHeight: compactHeight ? 44 : 48)
                .padding(.horizontal, 8)
                .background(isSelected ? Color.orange : Color.white.opacity(0.11))
                .foregroundStyle(isSelected ? Color.black : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct SettingOptionRow: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: systemImage ?? (isSelected ? "checkmark.circle.fill" : "circle"))
                    .foregroundStyle(isSelected ? Color.orange : Color.secondary)
                    .font(.system(size: 24, weight: .semibold))
            }
            .frame(minHeight: 54)
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
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isOn ? Color.orange : Color.secondary)
                    .font(.system(size: 24, weight: .semibold))
            }
            .frame(minHeight: 54)
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
                                .font(.system(size: 28, weight: .semibold, design: .rounded))
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

private struct PedagogicalDetailGroup: Identifiable {
    let id: String
    let title: String
    let lines: [CalculationLine]
}

private struct PedagogicalLineRow: View {
    let line: CalculationLine

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(line.label)
                    .font(line.isEmphasized ? .body.weight(.semibold) : .body)
                if line.isEmphasized {
                    Text("Point clé")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                }
            }

            Spacer(minLength: 16)

            Text(line.displayValue)
                .font(line.isEmphasized ? .body.weight(.semibold) : .body)
                .foregroundStyle(line.isEmphasized ? Color.orange : Color.primary)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
        }
        .padding(.vertical, 3)
    }
}

private enum PedagogicalDetailBuilder {
    static func groups(for result: CalculationResult) -> [PedagogicalDetailGroup] {
        var consumed = Set<String>()
        var groups: [PedagogicalDetailGroup] = []

        appendGroup(
            id: "start",
            title: "Montant de départ",
            matching: ["ht", "ttc", "target", "purchase_ht", "sale_ht", "required_ttc"],
            result: result,
            consumed: &consumed,
            groups: &groups
        )

        appendGroup(
            id: "vat",
            title: "TVA",
            matching: { $0.id.contains("vat") || $0.id == "franchise" },
            result: result,
            consumed: &consumed,
            groups: &groups
        )

        appendGroup(
            id: "base",
            title: "Base de calcul",
            matching: ["ca_ht", "required_ht", "profile", "rate"],
            result: result,
            consumed: &consumed,
            groups: &groups
        )

        appendGroup(
            id: "charges",
            title: "Charges",
            matching: ["social", "vfl", "cfp", "income_tax"],
            result: result,
            consumed: &consumed,
            groups: &groups
        )

        appendGroup(
            id: "remaining",
            title: "Ce qu'il reste",
            matching: ["reserve", "gross_margin", "margin_rate", "mark_rate"],
            result: result,
            consumed: &consumed,
            groups: &groups
        )

        let remainingLines = result.lines.filter { !consumed.contains($0.id) }
        if !remainingLines.isEmpty {
            groups.append(
                PedagogicalDetailGroup(
                    id: "other",
                    title: "Autres repères",
                    lines: remainingLines
                )
            )
        }

        return groups
    }

    private static func appendGroup(
        id: String,
        title: String,
        matching ids: Set<String>,
        result: CalculationResult,
        consumed: inout Set<String>,
        groups: inout [PedagogicalDetailGroup]
    ) {
        appendGroup(
            id: id,
            title: title,
            matching: { ids.contains($0.id) },
            result: result,
            consumed: &consumed,
            groups: &groups
        )
    }

    private static func appendGroup(
        id: String,
        title: String,
        matching predicate: (CalculationLine) -> Bool,
        result: CalculationResult,
        consumed: inout Set<String>,
        groups: inout [PedagogicalDetailGroup]
    ) {
        let lines = result.lines.filter { line in
            predicate(line) && !consumed.contains(line.id)
        }

        guard !lines.isEmpty else {
            return
        }

        lines.forEach { consumed.insert($0.id) }
        groups.append(PedagogicalDetailGroup(id: id, title: title, lines: lines))
    }
}

enum DecisionSummary {
    static func copyText(
        for state: CalculatorViewState,
        result: CalculationResult,
        ruleSet: TaxRuleSet
    ) -> String {
        let summary = lines(for: state, result: result, ruleSet: ruleSet)
            .joined(separator: "\n")

        return "\(result.mainLabel) : \(result.mainAmount.currencyText)\n\(summary)"
    }

    static func lines(
        for state: CalculatorViewState,
        result: CalculationResult,
        ruleSet: TaxRuleSet
    ) -> [String] {
        var lines: [String]

        switch state.selectedMode {
        case .vat:
            lines = vatLines(for: state, result: result)
        case .independent:
            lines = independentLines(for: state, result: result)
        case .netGoal:
            lines = netGoalLines(state: state, result: result)
        case .margin:
            lines = marginLines(result: result)
        }

        if let arithmeticError = state.arithmeticError {
            return ["\(arithmeticError)"] + lines
        }

        return lines
    }

    private static func vatLines(
        for state: CalculatorViewState,
        result: CalculationResult
    ) -> [String] {
        let ht = value("ht", in: result)
        let ttc = value("ttc", in: result)
        let vat = value("vat", in: result)

        switch state.vatCalculationKind {
        case .htToTTC:
            return [
                "Vous facturez \(ht) HT.",
                "Vous encaissez \(ttc) TTC.",
                "TVA à mettre de côté : \(vat)."
            ]
        case .ttcToHT:
            return [
                "Vous partez de \(ttc) TTC.",
                "Base hors taxe : \(ht).",
                "TVA incluse : \(vat)."
            ]
        case .vatOnly:
            return [
                "Base hors taxe : \(ht).",
                "TVA à isoler : \(vat).",
                "Taux utilisé : \(value("rate", in: result))."
            ]
        }
    }

    private static func independentLines(
        for state: CalculatorViewState,
        result: CalculationResult
    ) -> [String] {
        [
            "Montant HT : \(value("ca_ht", in: result)).",
            state.franchiseInBase ? "TVA non facturée." : "TVA à mettre de côté : \(value("vat", in: result)).",
            "Cotisations estimées : \(value("social", in: result)).",
            "Il te reste environ \(result.mainAmount.currencyText)."
        ]
    }

    private static func netGoalLines(
        state: CalculatorViewState,
        result: CalculationResult
    ) -> [String] {
        var lines = [
            "Objectif à garder : \(value("target", in: result)).",
            "Tu dois facturer environ \(value("required_ht", in: result)) HT."
        ]

        if state.vatApplicable {
            lines.append("Soit \(value("required_ttc", in: result)) TTC.")
            lines.append("TVA collectée : \(value("required_vat", in: result)).")
        }

        return lines
    }

    private static func marginLines(result: CalculationResult) -> [String] {
        [
            "Achat HT : \(value("purchase_ht", in: result)).",
            "Vente HT : \(value("sale_ht", in: result)).",
            "Marge brute : \(value("gross_margin", in: result))."
        ]
    }

    private static func value(_ id: String, in result: CalculationResult) -> String {
        result.lines.first { $0.id == id }?.displayValue ?? "0,00 €"
    }
}

private struct CalculationDetailView: View {
    let result: CalculationResult
    let ruleSet: TaxRuleSet

    private var groups: [PedagogicalDetailGroup] {
        PedagogicalDetailBuilder.groups(for: result)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Lecture rapide") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(result.mainLabel)
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        Text(result.mainAmount.currencyText)
                            .font(.system(size: 34, weight: .semibold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.45)
                    }
                    .padding(.vertical, 4)
                }

                ForEach(groups) { group in
                    Section(group.title) {
                        ForEach(group.lines) { line in
                            PedagogicalLineRow(line: line)
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
        .preferredColorScheme(.dark)
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
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(entry.mode.displayTitle)
                                    .font(.headline)
                                Spacer(minLength: 16)
                                Text(entry.mainAmount.currencyText)
                                    .font(.headline)
                                    .multilineTextAlignment(.trailing)
                            }

                            Text(entry.mainLabel)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(entry.formula)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
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
        .preferredColorScheme(.dark)
    }
}

private extension CalculationMode {
    var intentTitle: String {
        switch self {
        case .vat:
            return "TVA"
        case .independent:
            return "Reste net"
        case .netGoal:
            return "Objectif net"
        case .margin:
            return "Marge"
        }
    }

}

private extension VATCalculationKind {
    var shortTitle: String {
        switch self {
        case .htToTTC:
            return "HT vers TTC"
        case .ttcToHT:
            return "TTC vers HT"
        case .vatOnly:
            return "TVA seule"
        }
    }
}

#Preview {
    CalculatorShellView()
        .environment(EntitlementStore(service: PreviewStoreKitService()))
}
