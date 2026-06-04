import Foundation

enum CalculatorEntryField: String, Codable, Equatable {
    case amount
    case customVATRate
    case marginPurchase
    case marginSale
}

enum MarginInputField: String, CaseIterable, Codable, Identifiable {
    case purchase = "Achat"
    case sale = "Vente"

    var id: String { rawValue }
}

enum ArithmeticOperator: String, Equatable {
    case add = "+"
    case subtract = "−"
    case multiply = "×"
    case divide = "÷"
}

struct CalculationHistoryEntry: Equatable, Codable, Identifiable {
    let id: UUID
    let date: Date
    let mode: CalculationMode
    let mainLabel: String
    let mainAmount: Decimal
    let summary: String
    let formula: String

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        mode: CalculationMode,
        result: CalculationResult
    ) {
        self.id = id
        self.date = date
        self.mode = mode
        mainLabel = result.mainLabel
        mainAmount = result.mainAmount
        summary = result.copyText
        formula = result.formula
    }
}

struct DefaultCalculatorSettings: Equatable, Codable {
    var amountKind: AmountKind = .ht
    var purchaseKind: AmountKind = .ht
    var saleKind: AmountKind = .ht
    var selectedVATRateId = "vat_standard"
    var usesCustomVATRate = false
    var customVATRateText = "20"
    var selectedProfileId: TaxProfileID = .microBNCServiceGeneral
    var franchiseInBase = false
    var vflEnabled = false
    var includeCFPReserve = true
    var includeCFPInNetGoal = false
    var vatDeductibleOnPurchase = true

    static let standard = DefaultCalculatorSettings()
}

enum CalculatorDefaultsStore {
    private static let key = "calculette_fiscale.defaults.v1"

    static func load() -> DefaultCalculatorSettings {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return .standard
        }

        return (try? JSONDecoder().decode(DefaultCalculatorSettings.self, from: data)) ?? .standard
    }

    static func save(_ settings: DefaultCalculatorSettings) {
        guard let data = try? JSONEncoder().encode(settings) else {
            return
        }

        UserDefaults.standard.set(data, forKey: key)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

enum CalculationHistoryStore {
    private static let key = "calculette_fiscale.history.v1"
    private static let limit = 50

    static func load() -> [CalculationHistoryEntry] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }

        return (try? JSONDecoder().decode([CalculationHistoryEntry].self, from: data)) ?? []
    }

    static func save(_ entries: [CalculationHistoryEntry]) {
        let limitedEntries = Array(entries.prefix(limit))
        guard let data = try? JSONEncoder().encode(limitedEntries) else {
            return
        }

        UserDefaults.standard.set(data, forKey: key)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

struct CalculatorViewState: Equatable {
    var selectedMode: CalculationMode = .independent
    var amountText = "0"
    var customVATRateText = "20"
    var purchaseText = "0"
    var saleText = "0"
    var activeEntryField: CalculatorEntryField = .amount
    var activeMarginField: MarginInputField = .sale
    var vatCalculationKind: VATCalculationKind = .htToTTC
    var amountKind: AmountKind = .ht
    var purchaseKind: AmountKind = .ht
    var saleKind: AmountKind = .ht
    var selectedVATRateId = "vat_standard"
    var usesCustomVATRate = false
    var selectedProfileId: TaxProfileID = .microBNCServiceGeneral
    var franchiseInBase = false
    var vflEnabled = false
    var includeCFPReserve = true
    var includeCFPInNetGoal = false
    var vatDeductibleOnPurchase = true
    var pendingOperator: ArithmeticOperator?
    var storedOperand: Decimal?
    var arithmeticError: String?
    var shouldReplaceActiveText = false
    var history: [CalculationHistoryEntry] = CalculationHistoryStore.load()

    init() {}

    init(defaults: DefaultCalculatorSettings) {
        amountKind = defaults.amountKind
        purchaseKind = defaults.purchaseKind
        saleKind = defaults.saleKind
        selectedVATRateId = defaults.selectedVATRateId
        usesCustomVATRate = defaults.usesCustomVATRate
        customVATRateText = defaults.customVATRateText
        selectedProfileId = defaults.selectedProfileId
        franchiseInBase = defaults.franchiseInBase
        vflEnabled = defaults.vflEnabled
        includeCFPReserve = defaults.includeCFPReserve
        includeCFPInNetGoal = defaults.includeCFPInNetGoal
        vatDeductibleOnPurchase = defaults.vatDeductibleOnPurchase
    }

    var vatApplicable: Bool {
        !franchiseInBase
    }

    var activeText: String {
        switch activeEntryField {
        case .amount:
            return amountText
        case .customVATRate:
            return customVATRateText
        case .marginPurchase:
            return purchaseText
        case .marginSale:
            return saleText
        }
    }

    var activeFieldLabel: String {
        switch activeEntryField {
        case .amount:
            return selectedMode == .netGoal ? "Objectif net" : "Montant"
        case .customVATRate:
            return "Taux personnalisé"
        case .marginPurchase:
            return "Achat"
        case .marginSale:
            return "Vente"
        }
    }

    mutating func selectMode(_ mode: CalculationMode) {
        selectedMode = mode
        arithmeticError = nil

        switch mode {
        case .vat, .independent, .netGoal:
            activeEntryField = .amount
        case .margin:
            activeEntryField = activeMarginField == .purchase ? .marginPurchase : .marginSale
        }
    }

    mutating func selectVATRate(id: String) {
        usesCustomVATRate = false
        selectedVATRateId = id
        arithmeticError = nil
        restorePrimaryField()
    }

    mutating func selectCustomVATRate() {
        usesCustomVATRate = true
        activeEntryField = .customVATRate
        arithmeticError = nil
        if customVATRateText.isEmpty {
            customVATRateText = "20"
        }
    }

    mutating func selectMarginField(_ field: MarginInputField) {
        activeMarginField = field
        activeEntryField = field == .purchase ? .marginPurchase : .marginSale
        arithmeticError = nil
    }

    mutating func tapKey(_ key: String) {
        arithmeticError = nil

        switch key {
        case "C":
            setActiveText("0")
            pendingOperator = nil
            storedOperand = nil
            shouldReplaceActiveText = false
        case "⌫":
            deleteLastCharacter()
        case ",":
            appendDecimalSeparator()
        case "±":
            toggleSign()
        case "%":
            applyPercent()
        case "+", "−", "×", "÷":
            setPendingOperator(key)
        case "=":
            evaluatePendingOperation()
            restorePrimaryField()
        default:
            appendDigit(key)
        }
    }

    mutating func toggleFranchiseInBase() {
        arithmeticError = nil
        franchiseInBase.toggle()
    }

    mutating func addHistoryEntry(result: CalculationResult) {
        history.insert(CalculationHistoryEntry(mode: selectedMode, result: result), at: 0)
        history = Array(history.prefix(50))
        CalculationHistoryStore.save(history)
    }

    mutating func clearHistory() {
        history.removeAll()
        CalculationHistoryStore.clear()
    }

    func currentResult(ruleSet: TaxRuleSet = .french2026) -> CalculationResult {
        let rate = activeVATRate(ruleSet: ruleSet)

        switch selectedMode {
        case .vat:
            return TaxCalculationEngine.calculate(
                .vat(
                    VATCalculationInput(
                        amount: amount,
                        kind: vatCalculationKind,
                        rate: rate
                    )
                ),
                ruleSet: ruleSet
            )
        case .independent:
            return TaxCalculationEngine.calculate(
                .independent(
                    IndependentCalculationInput(
                        amount: amount,
                        amountKind: amountKind,
                        vatRate: rate,
                        vatApplicable: vatApplicable,
                        profileId: selectedProfileId,
                        vflEnabled: vflEnabled,
                        includeCFPInPrudentReserve: includeCFPReserve
                    )
                ),
                ruleSet: ruleSet
            )
        case .netGoal:
            return TaxCalculationEngine.calculate(
                .netGoal(
                    NetGoalCalculationInput(
                        targetNet: amount,
                        vatRate: rate,
                        vatApplicable: vatApplicable,
                        profileId: selectedProfileId,
                        vflEnabled: vflEnabled,
                        includeCFPInRequiredAmount: includeCFPInNetGoal
                    )
                ),
                ruleSet: ruleSet
            )
        case .margin:
            return TaxCalculationEngine.calculate(
                .margin(
                    MarginCalculationInput(
                        purchaseAmount: purchaseAmount,
                        purchaseKind: purchaseKind,
                        saleAmount: saleAmount,
                        saleKind: saleKind,
                        vatRate: rate,
                        vatApplicable: vatApplicable,
                        vatDeductibleOnPurchase: vatDeductibleOnPurchase
                    )
                ),
                ruleSet: ruleSet
            )
        }
    }

    func activeVATRate(ruleSet: TaxRuleSet = .french2026) -> Decimal {
        if usesCustomVATRate {
            return max(0, decimal(from: customVATRateText) / 100)
        }

        return ruleSet.vatRate(id: selectedVATRateId)?.rate ?? .fixed("0.20")
    }

    private var amount: Decimal {
        decimal(from: amountText)
    }

    private var purchaseAmount: Decimal {
        decimal(from: purchaseText)
    }

    private var saleAmount: Decimal {
        decimal(from: saleText)
    }

    private mutating func restorePrimaryField() {
        if selectedMode == .margin {
            activeEntryField = activeMarginField == .purchase ? .marginPurchase : .marginSale
        } else {
            activeEntryField = .amount
        }
    }

    private mutating func appendDigit(_ key: String) {
        guard key.allSatisfy(\.isNumber) else {
            return
        }

        if shouldReplaceActiveText {
            setActiveText("0")
            shouldReplaceActiveText = false
        }

        var text = activeText
        if text == "0" {
            guard key != "00" else {
                return
            }

            text = key
        } else if text == "-0" {
            text = "-\(key)"
        } else {
            text += key
        }

        setActiveText(text)
    }

    private mutating func appendDecimalSeparator() {
        if shouldReplaceActiveText {
            setActiveText("0")
            shouldReplaceActiveText = false
        }

        guard !activeText.contains(",") else {
            return
        }

        setActiveText(activeText + ",")
    }

    private mutating func deleteLastCharacter() {
        if shouldReplaceActiveText {
            setActiveText("0")
            shouldReplaceActiveText = false
            return
        }

        var text = activeText
        if text.count <= 1 || (text.count == 2 && text.hasPrefix("-")) {
            setActiveText("0")
            return
        }

        text.removeLast()
        setActiveText(text)
    }

    private mutating func toggleSign() {
        guard activeEntryField != .customVATRate else {
            return
        }

        if shouldReplaceActiveText {
            shouldReplaceActiveText = false
        }

        let text = activeText
        if text.hasPrefix("-") {
            setActiveText(String(text.dropFirst()))
        } else if text != "0" {
            setActiveText("-\(text)")
        }
    }

    private mutating func applyPercent() {
        let percent = decimal(from: activeText) / 100
        setActiveText(inputText(from: percent))
    }

    private mutating func setPendingOperator(_ key: String) {
        if pendingOperator != nil && !shouldReplaceActiveText {
            evaluatePendingOperation()
        }

        storedOperand = decimal(from: activeText)
        pendingOperator = ArithmeticOperator(rawValue: key)
        shouldReplaceActiveText = true
        arithmeticError = nil
    }

    private mutating func evaluatePendingOperation() {
        guard let pendingOperator, let storedOperand else {
            shouldReplaceActiveText = false
            return
        }

        let currentOperand = decimal(from: activeText)
        let result: Decimal

        switch pendingOperator {
        case .add:
            result = storedOperand + currentOperand
        case .subtract:
            result = storedOperand - currentOperand
        case .multiply:
            result = storedOperand * currentOperand
        case .divide:
            guard currentOperand != 0 else {
                let fallback = inputText(from: storedOperand)
                setActiveText(fallback)
                arithmeticError = "Division par zéro impossible."
                self.pendingOperator = nil
                self.storedOperand = nil
                shouldReplaceActiveText = true
                return
            }

            result = storedOperand / currentOperand
            arithmeticError = nil
        }

        setActiveText(inputText(from: result))
        self.pendingOperator = nil
        self.storedOperand = nil
        shouldReplaceActiveText = true
        arithmeticError = nil
    }

    private mutating func setActiveText(_ value: String) {
        arithmeticError = nil
        switch activeEntryField {
        case .amount:
            amountText = value
        case .customVATRate:
            customVATRateText = value
        case .marginPurchase:
            purchaseText = value
        case .marginSale:
            saleText = value
        }
    }

    private func decimal(from text: String) -> Decimal {
        let normalized = text
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")

        return Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX")) ?? 0
    }

    private func inputText(from value: Decimal) -> String {
        let rounded = value.rounded(scale: 6)
        let number = rounded as NSDecimalNumber
        return InputFormatterFactory.inputText.string(from: number) ?? "0"
    }
}

private enum InputFormatterFactory {
    static let inputText: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6
        return formatter
    }()
}
