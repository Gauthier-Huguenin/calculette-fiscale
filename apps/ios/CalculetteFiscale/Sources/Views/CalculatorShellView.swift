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
    @State private var copyFeedback = false
    @State private var lockedPreviewMode: CalculationMode?

    init(screenshotScenario: ScreenshotScenario? = nil) {
        self.screenshotScenario = screenshotScenario
        _state = State(initialValue: screenshotScenario?.state ?? CalculatorViewState())
        _isShowingDetails = State(initialValue: screenshotScenario?.presentedSheet == .details)
        _isShowingHistory = State(initialValue: screenshotScenario?.presentedSheet == .history)
        _isShowingSettings = State(initialValue: screenshotScenario?.presentedSheet == .settings)
    }

    var body: some View {
        let result = state.currentResult(ruleSet: ruleSet)

        GeometryReader { proxy in
            let compactHeight = proxy.size.height < 900
            let keyHeight = min(compactHeight ? 52 : 64, max(46, proxy.size.height * 0.061))
            let bottomPadding = max(compactHeight ? 18 : 14, proxy.safeAreaInsets.bottom + 8)

            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: compactHeight ? 8 : 12) {
                    HeaderBar(
                        onHistory: openHistory,
                        isPro: entitlementStore.isPro,
                        historyCount: state.history.count
                    )

                    ModeSelector(
                        state: $state,
                        isPro: entitlementStore.isPro,
                        onLockedMode: showLockedPreview
                    )

                    ResultPanel(
                        state: state,
                        result: result,
                        ruleSet: ruleSet,
                        compactHeight: compactHeight,
                        copyFeedback: copyFeedback,
                        onCopy: { copyResult(result) }
                    )
                    .layoutPriority(1)

                    EssentialControls(
                        state: $state,
                        compactHeight: compactHeight
                    )

                    ActionBar(
                        isPro: entitlementStore.isPro,
                        onSettings: { isShowingSettings = true },
                        onDetails: openDetails
                    )

                    NumericKeypad(keyHeight: keyHeight) { key in
                        handleKey(key)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, compactHeight ? 8 : 14)
                .padding(.bottom, bottomPadding)
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
            CalculationSettingsView(
                state: $state,
                ruleSet: ruleSet,
                isPro: entitlementStore.isPro,
                onLockedMode: showLockedPreviewFromSettings
            )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $lockedPreviewMode) { mode in
            LockedModePreviewView(
                mode: mode,
                onShowPaywall: {
                    lockedPreviewMode = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                        showPaywall()
                    }
                }
            )
            .presentationDetents([.medium])
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

    private func showLockedPreview(_ mode: CalculationMode) {
        lockedPreviewMode = mode
    }

    private func showLockedPreviewFromSettings(_ mode: CalculationMode) {
        isShowingSettings = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            lockedPreviewMode = mode
        }
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
    let isPro: Bool
    let onLockedMode: (CalculationMode) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(CalculationMode.allCases) { mode in
                ModeButton(
                    title: mode.intentTitle,
                    isSelected: state.selectedMode == mode,
                    isLocked: mode.requiresPro && !isPro,
                    action: {
                        if ProAccessPolicy.isAllowed(.mode(mode), isPro: isPro) {
                            state.selectMode(mode)
                        } else {
                            onLockedMode(mode)
                        }
                    }
                )
            }
        }
    }
}

private struct ModeButton: View {
    let title: String
    let isSelected: Bool
    let isLocked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10, weight: .bold))
                }

                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.72)
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .padding(.horizontal, 6)
            .background(isSelected ? Color.white : Color.white.opacity(0.11))
            .foregroundStyle(isSelected ? Color.black : Color.white.opacity(isLocked ? 0.58 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isLocked ? "Mode \(title) verrouillé" : "Mode \(title)")
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
                title: isPro ? "Détail" : "Détail Pro",
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

private struct LockedModePreviewView: View {
    @Environment(\.dismiss) private var dismiss

    let mode: CalculationMode
    let onShowPaywall: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 22) {
                Image(systemName: mode.previewIcon)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.orange)
                    .frame(width: 54, height: 54)
                    .background(Color.orange.opacity(0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 10) {
                    Text(mode.intentTitle)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(mode.lockedPreviewPromise)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text(mode.lockedPreviewExample)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.86))
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Spacer()

                Button(action: onShowPaywall) {
                    Label("Voir la version Pro", systemImage: "lock.open.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(Color.orange)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(22)
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Aperçu Pro")
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
    }
}

private struct CalculationSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var state: CalculatorViewState
    let ruleSet: TaxRuleSet
    let isPro: Bool
    let onLockedMode: (CalculationMode) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    CurrentModeSummary(state: state, ruleSet: ruleSet)
                }

                Section("Que voulez-vous calculer ?") {
                    ForEach(CalculationMode.allCases) { mode in
                        SettingOptionRow(
                            title: mode.intentTitle,
                            subtitle: mode.settingsDescription,
                            isSelected: state.selectedMode == mode,
                            systemImage: mode.requiresPro && !isPro ? "lock.fill" : nil,
                            action: {
                                if ProAccessPolicy.isAllowed(.mode(mode), isPro: isPro) {
                                    state.selectMode(mode)
                                } else {
                                    dismiss()
                                    onLockedMode(mode)
                                }
                            }
                        )
                    }
                }

                Section("Comment lire le montant saisi ?") {
                    modeSettings
                }

                Section(vatSectionTitle) {
                    vatSettings
                }

                Section("Prudence") {
                    Text("Barèmes vérifiés le 14/05/2026")
                        .font(.body.weight(.semibold))

                    Text("Estimation indicative. Cette calculette ne remplace pas une déclaration officielle ni un conseil adapté à votre situation.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Réglages")
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
    private var modeSettings: some View {
        switch state.selectedMode {
        case .vat:
            ForEach(VATCalculationKind.allCases) { kind in
                SettingOptionRow(
                    title: vatKindQuestionTitle(kind),
                    subtitle: vatKindSubtitle(kind),
                    isSelected: state.vatCalculationKind == kind,
                    action: {
                        state.vatCalculationKind = kind
                        state.activeEntryField = .amount
                    }
                )
            }
        case .independent:
            profileRows(question: "Quel profil utiliser ?")
            amountKindRows(selection: $state.amountKind, prefix: "Montant saisi")
            SettingToggleRow(
                title: "Versement libératoire",
                subtitle: "Ajoute l'estimation du versement libératoire au calcul.",
                isOn: state.vflEnabled,
                action: { state.vflEnabled.toggle() }
            )
            SettingToggleRow(
                title: "Inclure la CFP",
                subtitle: "Ajoute une réserve prudente pour la CFP.",
                isOn: state.includeCFPReserve,
                action: { state.includeCFPReserve.toggle() }
            )
        case .netGoal:
            profileRows(question: "Quel profil utiliser ?")
            SettingToggleRow(
                title: "Versement libératoire",
                subtitle: "Intègre le versement libératoire dans le prix à facturer.",
                isOn: state.vflEnabled,
                action: { state.vflEnabled.toggle() }
            )
            SettingToggleRow(
                title: "Inclure la CFP",
                subtitle: "Majore le montant HT nécessaire pour couvrir la CFP.",
                isOn: state.includeCFPInNetGoal,
                action: { state.includeCFPInNetGoal.toggle() }
            )
        case .margin:
            ForEach(MarginInputField.allCases) { field in
                SettingOptionRow(
                    title: "Le clavier modifie \(field.rawValue.lowercased())",
                    subtitle: "Le clavier modifie ce montant.",
                    isSelected: state.activeMarginField == field,
                    action: { state.selectMarginField(field) }
                )
            }
            amountKindRows(selection: $state.purchaseKind, prefix: "Achat")
            amountKindRows(selection: $state.saleKind, prefix: "Vente")
            SettingToggleRow(
                title: "TVA déductible",
                subtitle: "Déduit la TVA de l'achat dans le calcul de TVA nette.",
                isOn: state.vatDeductibleOnPurchase,
                action: { state.vatDeductibleOnPurchase.toggle() }
            )
        }
    }

    private var vatSectionTitle: String {
        state.selectedMode == .vat ? "Quel taux de TVA utiliser ?" : "Facturez-vous la TVA ?"
    }

    @ViewBuilder
    private var vatSettings: some View {
        if state.selectedMode != .vat {
            SettingToggleRow(
                title: state.franchiseInBase ? "Non, je suis en franchise en base" : "Oui, je facture la TVA",
                subtitle: state.franchiseInBase ? "La TVA est neutralisée dans le calcul." : "La TVA est calculée avec le taux choisi.",
                isOn: !state.franchiseInBase,
                action: { state.toggleFranchiseInBase() }
            )
        }

        if !state.franchiseInBase || state.selectedMode == .vat {
            ForEach(ruleSet.vatRates) { rate in
                SettingOptionRow(
                    title: "Taux \(rate.label)",
                    subtitle: "Utiliser ce taux pour les montants HT, TTC et TVA.",
                    isSelected: !state.usesCustomVATRate && state.selectedVATRateId == rate.id,
                    action: { state.selectVATRate(id: rate.id) }
                )
            }

            SettingOptionRow(
                title: "Taux personnalisé",
                subtitle: "Le clavier saisit le pourcentage à utiliser.",
                isSelected: state.usesCustomVATRate,
                action: {
                    state.selectCustomVATRate()
                    dismiss()
                }
            )
        }
    }

    private func profileRows(question: String) -> some View {
        Group {
            Text(question)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            ForEach(ruleSet.microProfiles) { profile in
                SettingOptionRow(
                    title: profile.label,
                    subtitle: "Utiliser ce profil pour les cotisations estimées.",
                    isSelected: state.selectedProfileId == profile.id,
                    action: { state.selectedProfileId = profile.id }
                )
            }
        }
    }

    private func amountKindRows(
        selection: Binding<AmountKind>,
        prefix: String
    ) -> some View {
        Group {
            SettingOptionRow(
                title: "\(prefix) HT",
                subtitle: "Le montant est hors taxe.",
                isSelected: selection.wrappedValue == .ht,
                action: { selection.wrappedValue = .ht }
            )
            SettingOptionRow(
                title: "\(prefix) TTC",
                subtitle: "Le montant inclut la TVA.",
                isSelected: selection.wrappedValue == .ttc,
                action: { selection.wrappedValue = .ttc }
            )
        }
    }

    private func vatKindSubtitle(_ kind: VATCalculationKind) -> String {
        switch kind {
        case .htToTTC:
            return "Partir d'un montant HT pour obtenir le TTC."
        case .ttcToHT:
            return "Partir d'un montant TTC pour retrouver le HT."
        case .vatOnly:
            return "Afficher uniquement le montant de TVA."
        }
    }

    private func vatKindQuestionTitle(_ kind: VATCalculationKind) -> String {
        switch kind {
        case .htToTTC:
            return "Je pars du HT"
        case .ttcToHT:
            return "Je pars du TTC"
        case .vatOnly:
            return "Je veux seulement la TVA"
        }
    }
}

private struct CurrentModeSummary: View {
    let state: CalculatorViewState
    let ruleSet: TaxRuleSet

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(state.selectedMode.intentTitle)
                .font(.title3.weight(.semibold))

            Text(summaryText)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }

    private var summaryText: String {
        let rate = state.activeVATRate(ruleSet: ruleSet).percentText

        switch state.selectedMode {
        case .vat:
            return "Calcul \(state.vatCalculationKind.rawValue), avec TVA \(rate)."
        case .independent:
            return "\(profileShortLabel), montant \(state.amountKind.rawValue), \(state.franchiseInBase ? "franchise en base" : "TVA \(rate)")."
        case .netGoal:
            return "\(profileShortLabel), \(state.franchiseInBase ? "sans TVA" : "TVA \(rate)")."
        case .margin:
            return "\(state.activeMarginField.rawValue) actif, achat \(state.purchaseKind.rawValue), vente \(state.saleKind.rawValue), \(state.franchiseInBase ? "sans TVA" : "TVA \(rate)")."
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
            "Base cotisations : \(value("ca_ht", in: result)).",
            state.franchiseInBase ? "TVA non facturée." : "TVA à mettre de côté : \(value("vat", in: result)).",
            "Net estimé : \(result.mainAmount.currencyText)."
        ]
    }

    private static func netGoalLines(
        state: CalculatorViewState,
        result: CalculationResult
    ) -> [String] {
        var lines = [
            "Objectif à garder : \(value("target", in: result)).",
            "À facturer HT : \(value("required_ht", in: result))."
        ]

        if state.vatApplicable {
            lines.append("TTC indicatif : \(value("required_ttc", in: result)).")
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
            return "Je convertis TVA"
        case .independent:
            return "Je facture"
        case .netGoal:
            return "Je veux garder"
        case .margin:
            return "Je vérifie une marge"
        }
    }

    var settingsDescription: String {
        switch self {
        case .vat:
            return "Convertir HT, TTC ou TVA seule."
        case .independent:
            return "Estimer le net après cotisations."
        case .netGoal:
            return "Remonter d'un objectif net vers un prix."
        case .margin:
            return "Comparer achat, vente, marge et TVA nette."
        }
    }

    var previewIcon: String {
        switch self {
        case .vat:
            return "percent"
        case .independent:
            return "person.crop.circle.badge.checkmark"
        case .netGoal:
            return "target"
        case .margin:
            return "chart.line.uptrend.xyaxis"
        }
    }

    var lockedPreviewPromise: String {
        switch self {
        case .vat:
            return "Convertissez rapidement HT, TTC et TVA."
        case .independent:
            return "Voyez ce qu'il reste vraiment après TVA et cotisations estimées."
        case .netGoal:
            return "Partez du montant à garder et obtenez un prix HT à facturer."
        case .margin:
            return "Vérifiez si une vente reste rentable une fois la TVA sortie."
        }
    }

    var lockedPreviewExample: String {
        switch self {
        case .vat:
            return "Exemple : 100 € HT deviennent 120 € TTC avec une TVA de 20 €."
        case .independent:
            return "Exemple : sur 1 200 € TTC, distinguez TVA, CA HT, cotisations et net indicatif."
        case .netGoal:
            return "Exemple : pour garder 2 500 €, obtenez le montant HT à facturer."
        case .margin:
            return "Exemple : achat 72 € TTC, vente 120 € TTC, marge et TVA nette en un coup d'oeil."
        }
    }
}

#Preview {
    CalculatorShellView()
        .environment(EntitlementStore(service: PreviewStoreKitService()))
}
