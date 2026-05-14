import XCTest
@testable import CalculetteFiscale

final class VATCalculatorTests: XCTestCase {
    override func setUp() {
        super.setUp()
        CalculationHistoryStore.clear()
    }

    override func tearDown() {
        CalculationHistoryStore.clear()
        super.tearDown()
    }

    func testHTToTTCAtTwentyPercent() {
        let result = VATCalculator.fromHT(100, rate: .fixed("0.20"))

        XCTAssertCurrency(result.htAmount, "100.00")
        XCTAssertCurrency(result.vatAmount, "20.00")
        XCTAssertCurrency(result.ttcAmount, "120.00")
    }

    func testTTCToHTAtTwentyPercent() {
        let result = VATCalculator.fromTTC(120, rate: .fixed("0.20"))

        XCTAssertCurrency(result.htAmount, "100.00")
        XCTAssertCurrency(result.vatAmount, "20.00")
        XCTAssertCurrency(result.ttcAmount, "120.00")
    }

    func testVATRatesFromRuleset() {
        let ruleSet = TaxRuleSet.french2026

        XCTAssertEqual(ruleSet.vatRate(id: "vat_standard")?.rate, .fixed("0.20"))
        XCTAssertEqual(ruleSet.vatRate(id: "vat_intermediate")?.rate, .fixed("0.10"))
        XCTAssertEqual(ruleSet.vatRate(id: "vat_reduced")?.rate, .fixed("0.055"))
        XCTAssertEqual(ruleSet.vatRate(id: "vat_special")?.rate, .fixed("0.021"))
    }

    func testHTToTTCAtReducedRate() {
        let result = VATCalculator.fromHT(100, rate: .fixed("0.055"))

        XCTAssertCurrency(result.htAmount, "100.00")
        XCTAssertCurrency(result.vatAmount, "5.50")
        XCTAssertCurrency(result.ttcAmount, "105.50")
    }

    func testTTCToHTAtReducedRate() {
        let result = VATCalculator.fromTTC(.fixed("105.50"), rate: .fixed("0.055"))

        XCTAssertCurrency(result.htAmount, "100.00")
        XCTAssertCurrency(result.vatAmount, "5.50")
        XCTAssertCurrency(result.ttcAmount, "105.50")
    }

    func testVATOnlyAtCustomRate() {
        let result = TaxCalculationEngine.calculate(
            .vat(
                VATCalculationInput(
                    amount: 100,
                    kind: .vatOnly,
                    rate: .fixed("0.15")
                )
            )
        )

        XCTAssertCurrency(result.mainAmount, "15.00")
        XCTAssertEqual(result.mainLabel, "TVA seule")
    }

    func testMicroBICSaleFromHT() {
        let result = independentResult(profile: .microBICSale, amount: 1000, amountKind: .ht)

        XCTAssertLine(result, "social", equals: "123.00")
        XCTAssertLine(result, "vat", equals: "200.00")
        XCTAssertCurrency(result.mainAmount, "877.00")
    }

    func testMicroBICServiceFromHT() {
        let result = independentResult(profile: .microBICService, amount: 1000, amountKind: .ht)

        XCTAssertLine(result, "social", equals: "212.00")
        XCTAssertLine(result, "vat", equals: "200.00")
        XCTAssertCurrency(result.mainAmount, "788.00")
    }

    func testMicroBNCGeneralUsesTwentyFivePointSixPercent() {
        let result = independentResult(profile: .microBNCServiceGeneral, amount: 1000, amountKind: .ht)

        XCTAssertLine(result, "social", equals: "256.00")
        XCTAssertLine(result, "vat", equals: "200.00")
        XCTAssertCurrency(result.mainAmount, "744.00")
    }

    func testMicroBNCGeneralFromTTC() {
        let result = independentResult(profile: .microBNCServiceGeneral, amount: 1200, amountKind: .ttc)

        XCTAssertLine(result, "ca_ht", equals: "1000.00")
        XCTAssertLine(result, "vat", equals: "200.00")
        XCTAssertLine(result, "social", equals: "256.00")
        XCTAssertCurrency(result.mainAmount, "744.00")
    }

    func testMicroBNCGeneralWithVersementLiberatoire() {
        let result = TaxCalculationEngine.calculate(
            .independent(
                IndependentCalculationInput(
                    amount: 1000,
                    amountKind: .ht,
                    vatRate: .fixed("0.20"),
                    vatApplicable: true,
                    profileId: .microBNCServiceGeneral,
                    vflEnabled: true,
                    includeCFPInPrudentReserve: true
                )
            )
        )

        XCTAssertLine(result, "social", equals: "256.00")
        XCTAssertLine(result, "vfl", equals: "22.00")
        XCTAssertCurrency(result.mainAmount, "722.00")
    }

    func testNetGoalForMicroProfiles() {
        XCTAssertCurrency(netGoalResult(profile: .microBICSale, target: 877).mainAmount, "1000.00")
        XCTAssertCurrency(netGoalResult(profile: .microBICService, target: 788).mainAmount, "1000.00")
        XCTAssertCurrency(netGoalResult(profile: .microBNCServiceGeneral, target: 744).mainAmount, "1000.00")
    }

    func testNetGoalForMicroBNCWithVersementLiberatoire() {
        let result = TaxCalculationEngine.calculate(
            .netGoal(
                NetGoalCalculationInput(
                    targetNet: 722,
                    vatRate: .fixed("0.20"),
                    vatApplicable: true,
                    profileId: .microBNCServiceGeneral,
                    vflEnabled: true,
                    includeCFPInRequiredAmount: false
                )
            )
        )

        XCTAssertCurrency(result.mainAmount, "1000.00")
        XCTAssertLine(result, "required_ttc", equals: "1200.00")
    }

    func testMarginFromHTAmounts() {
        let result = marginResult(
            purchase: 60,
            purchaseKind: .ht,
            sale: 100,
            saleKind: .ht,
            vatApplicable: true
        )

        XCTAssertCurrency(result.mainAmount, "40.00")
        XCTAssertLine(result, "margin_rate", equals: "0.6667")
        XCTAssertLine(result, "mark_rate", equals: "0.4000")
        XCTAssertLine(result, "net_vat", equals: "8.00")
    }

    func testMarginFromTTCAmounts() {
        let result = marginResult(
            purchase: 72,
            purchaseKind: .ttc,
            sale: 120,
            saleKind: .ttc,
            vatApplicable: true
        )

        XCTAssertLine(result, "purchase_ht", equals: "60.00")
        XCTAssertLine(result, "sale_ht", equals: "100.00")
        XCTAssertCurrency(result.mainAmount, "40.00")
        XCTAssertLine(result, "net_vat", equals: "8.00")
    }

    func testMarginInFranchiseInBaseHasNoVAT() {
        let result = marginResult(
            purchase: 60,
            purchaseKind: .ht,
            sale: 100,
            saleKind: .ht,
            vatApplicable: false
        )

        XCTAssertLine(result, "vat_collected", equals: "0.00")
        XCTAssertLine(result, "vat_deductible", equals: "0.00")
        XCTAssertLine(result, "net_vat", equals: "0.00")
    }

    func testStateHandlesFrenchDecimalInputAndDelete() {
        var state = CalculatorViewState()

        state.tapKey("1")
        state.tapKey("2")
        state.tapKey(",")
        state.tapKey("3")
        state.tapKey("⌫")

        XCTAssertEqual(state.amountText, "12,")
        XCTAssertCurrency(state.currentResult().lines.first { $0.id == "ht" }?.amount ?? 0, "12.00")
    }

    func testStateSwitchesModeAndActiveMarginField() {
        var state = CalculatorViewState()

        state.selectMode(.margin)
        state.selectMarginField(.purchase)
        state.tapKey("6")
        state.tapKey("0")

        XCTAssertEqual(state.activeEntryField, .marginPurchase)
        XCTAssertEqual(state.purchaseText, "60")
    }

    func testStateHandlesBasicArithmetic() {
        var state = CalculatorViewState()

        state.tapKey("1")
        state.tapKey("0")
        state.tapKey("+")
        state.tapKey("5")
        state.tapKey("=")

        XCTAssertEqual(state.amountText, "15")
        XCTAssertCurrency(state.currentResult().lines.first { $0.id == "ht" }?.amount ?? 0, "15.00")
    }

    func testStateHandlesPercentKey() {
        var state = CalculatorViewState()

        state.tapKey("5")
        state.tapKey("0")
        state.tapKey("%")

        XCTAssertEqual(state.amountText, "0,5")
    }

    func testHistoryPersistsLocally() {
        var state = CalculatorViewState()
        let result = state.currentResult()

        state.addHistoryEntry(result: result)

        XCTAssertEqual(CalculationHistoryStore.load().count, 1)
    }

    private func independentResult(
        profile: TaxProfileID,
        amount: Decimal,
        amountKind: AmountKind
    ) -> CalculationResult {
        TaxCalculationEngine.calculate(
            .independent(
                IndependentCalculationInput(
                    amount: amount,
                    amountKind: amountKind,
                    vatRate: .fixed("0.20"),
                    vatApplicable: true,
                    profileId: profile,
                    vflEnabled: false,
                    includeCFPInPrudentReserve: true
                )
            )
        )
    }

    private func netGoalResult(profile: TaxProfileID, target: Decimal) -> CalculationResult {
        TaxCalculationEngine.calculate(
            .netGoal(
                NetGoalCalculationInput(
                    targetNet: target,
                    vatRate: .fixed("0.20"),
                    vatApplicable: true,
                    profileId: profile,
                    vflEnabled: false,
                    includeCFPInRequiredAmount: false
                )
            )
        )
    }

    private func marginResult(
        purchase: Decimal,
        purchaseKind: AmountKind,
        sale: Decimal,
        saleKind: AmountKind,
        vatApplicable: Bool
    ) -> CalculationResult {
        TaxCalculationEngine.calculate(
            .margin(
                MarginCalculationInput(
                    purchaseAmount: purchase,
                    purchaseKind: purchaseKind,
                    saleAmount: sale,
                    saleKind: saleKind,
                    vatRate: .fixed("0.20"),
                    vatApplicable: vatApplicable,
                    vatDeductibleOnPurchase: true
                )
            )
        )
    }

    private func XCTAssertCurrency(
        _ value: Decimal,
        _ expected: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(value.currencyRounded, Decimal.fixed(expected), file: file, line: line)
    }

    private func XCTAssertLine(
        _ result: CalculationResult,
        _ id: String,
        equals expected: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let amount = result.lines.first(where: { $0.id == id })?.amount else {
            XCTFail("Missing line \(id)", file: file, line: line)
            return
        }

        XCTAssertEqual(amount, Decimal.fixed(expected), file: file, line: line)
    }
}
