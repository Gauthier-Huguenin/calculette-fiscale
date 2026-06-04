import Foundation

enum CalculationMode: String, CaseIterable, Codable, Identifiable {
    case vat = "TVA"
    case independent = "Indépendant"
    case netGoal = "Objectif net"
    case margin = "Marge"

    var id: String { rawValue }

    var displayTitle: String {
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

enum AmountKind: String, CaseIterable, Codable, Identifiable {
    case ht = "HT"
    case ttc = "TTC"

    var id: String { rawValue }
}

enum VATCalculationKind: String, CaseIterable, Codable, Identifiable {
    case htToTTC = "HT → TTC"
    case ttcToHT = "TTC → HT"
    case vatOnly = "TVA seule"

    var id: String { rawValue }
}

enum TaxProfileID: String, CaseIterable, Codable, Identifiable {
    case microBICSale = "micro_bic_sale"
    case microBICService = "micro_bic_service"
    case microBNCServiceGeneral = "micro_bnc_service_general"

    var id: String { rawValue }
}

struct VATRate: Equatable, Codable, Identifiable {
    let id: String
    let label: String
    let rate: Decimal
}

struct DecimalRateRange: Equatable, Codable {
    let lower: Decimal
    let upper: Decimal
}

struct TaxProfile: Equatable, Codable, Identifiable {
    let id: TaxProfileID
    let label: String
    let socialContributionRate: Decimal
    let vflIncomeTaxRate: Decimal
    let cfpRate: Decimal?
    let cfpRateRange: DecimalRateRange?
    let incomeTaxAbatementRate: Decimal
    let microThreshold: Decimal
    let vatFranchiseBaseThreshold: Decimal
    let vatFranchiseMajorThreshold: Decimal
    let warnings: [String]

    var cfpReserveRate: Decimal {
        cfpRate ?? cfpRateRange?.upper ?? 0
    }

    var cfpLabel: String {
        if let cfpRate {
            return "\(cfpRate.percentText) annuelle indicative"
        }

        if let range = cfpRateRange {
            return "\(range.lower.percentText) à \(range.upper.percentText) annuelle indicative"
        }

        return "Non renseignée"
    }
}

struct TaxRuleSet: Equatable, Codable, Identifiable {
    let id: String
    let country: String
    let effectiveFrom: Date
    let checkedAt: Date
    let sources: [String]
    let vatRates: [VATRate]
    let microProfiles: [TaxProfile]

    func vatRate(id: String) -> VATRate? {
        vatRates.first { $0.id == id }
    }

    func microProfile(id: TaxProfileID) -> TaxProfile {
        microProfiles.first { $0.id == id } ?? microProfiles[0]
    }
}

extension TaxRuleSet {
    static let french2026 = TaxRuleSet(
        id: "fr-2026-v1-2026-05-14",
        country: "France",
        effectiveFrom: DateComponents(
            calendar: Calendar(identifier: .gregorian),
            year: 2026,
            month: 1,
            day: 1
        ).date ?? Date(timeIntervalSince1970: 1_767_225_600),
        checkedAt: DateComponents(
            calendar: Calendar(identifier: .gregorian),
            year: 2026,
            month: 5,
            day: 14
        ).date ?? Date(timeIntervalSince1970: 1_747_180_800),
        sources: [
            "Direction générale des douanes et droits indirects, Les taux de TVA, mise à jour le 27/04/2021",
            "Entreprendre Service-Public, Franchise en base de TVA, vérifié le 01/01/2026",
            "impots.gouv.fr, Obligations TVA micro-entreprise, modifié le 29/04/2026",
            "Entreprendre Service-Public, Nouveaux seuils de la micro-entreprise, publié le 26/02/2026",
            "Entreprendre Service-Public, Cotisations sociales micro-entrepreneur, vérifié le 01/01/2026",
            "impots.gouv.fr, Le versement libératoire"
        ],
        vatRates: [
            VATRate(id: "vat_standard", label: "20 %", rate: .fixed("0.20")),
            VATRate(id: "vat_intermediate", label: "10 %", rate: .fixed("0.10")),
            VATRate(id: "vat_reduced", label: "5,5 %", rate: .fixed("0.055")),
            VATRate(id: "vat_special", label: "2,1 %", rate: .fixed("0.021"))
        ],
        microProfiles: [
            TaxProfile(
                id: .microBICSale,
                label: "Micro-BIC vente",
                socialContributionRate: .fixed("0.123"),
                vflIncomeTaxRate: .fixed("0.010"),
                cfpRate: .fixed("0.001"),
                cfpRateRange: nil,
                incomeTaxAbatementRate: .fixed("0.71"),
                microThreshold: .fixed("203100"),
                vatFranchiseBaseThreshold: .fixed("85000"),
                vatFranchiseMajorThreshold: .fixed("93500"),
                warnings: ["Activités mixtes, locations et cas particuliers hors V1."]
            ),
            TaxProfile(
                id: .microBICService,
                label: "Micro-BIC prestation",
                socialContributionRate: .fixed("0.212"),
                vflIncomeTaxRate: .fixed("0.017"),
                cfpRate: nil,
                cfpRateRange: DecimalRateRange(lower: .fixed("0.001"), upper: .fixed("0.003")),
                incomeTaxAbatementRate: .fixed("0.50"),
                microThreshold: .fixed("83600"),
                vatFranchiseBaseThreshold: .fixed("37500"),
                vatFranchiseMajorThreshold: .fixed("41250"),
                warnings: ["CFP variable selon activité commerciale ou artisanale."]
            ),
            TaxProfile(
                id: .microBNCServiceGeneral,
                label: "Micro-BNC prestation",
                socialContributionRate: .fixed("0.256"),
                vflIncomeTaxRate: .fixed("0.022"),
                cfpRate: .fixed("0.002"),
                cfpRateRange: nil,
                incomeTaxAbatementRate: .fixed("0.34"),
                microThreshold: .fixed("83600"),
                vatFranchiseBaseThreshold: .fixed("37500"),
                vatFranchiseMajorThreshold: .fixed("41250"),
                warnings: ["Le profil Cipav est hors scope V1."]
            )
        ]
    )
}

enum CalculationInput: Equatable {
    case vat(VATCalculationInput)
    case independent(IndependentCalculationInput)
    case netGoal(NetGoalCalculationInput)
    case margin(MarginCalculationInput)
}

struct VATCalculationInput: Equatable {
    let amount: Decimal
    let kind: VATCalculationKind
    let rate: Decimal
}

struct IndependentCalculationInput: Equatable {
    let amount: Decimal
    let amountKind: AmountKind
    let vatRate: Decimal
    let vatApplicable: Bool
    let profileId: TaxProfileID
    let vflEnabled: Bool
    let includeCFPInPrudentReserve: Bool
}

struct NetGoalCalculationInput: Equatable {
    let targetNet: Decimal
    let vatRate: Decimal
    let vatApplicable: Bool
    let profileId: TaxProfileID
    let vflEnabled: Bool
    let includeCFPInRequiredAmount: Bool
}

struct MarginCalculationInput: Equatable {
    let purchaseAmount: Decimal
    let purchaseKind: AmountKind
    let saleAmount: Decimal
    let saleKind: AmountKind
    let vatRate: Decimal
    let vatApplicable: Bool
    let vatDeductibleOnPurchase: Bool
}

struct CalculationWarning: Equatable, Codable, Identifiable {
    let id: String
    let message: String
}

struct CalculationLine: Equatable, Codable, Identifiable {
    enum ValueKind: String, Codable {
        case currency
        case percent
        case text
    }

    let id: String
    let label: String
    let amount: Decimal?
    let text: String?
    let valueKind: ValueKind
    let isEmphasized: Bool

    static func currency(
        id: String,
        label: String,
        amount: Decimal,
        isEmphasized: Bool = false
    ) -> CalculationLine {
        CalculationLine(
            id: id,
            label: label,
            amount: amount.currencyRounded,
            text: nil,
            valueKind: .currency,
            isEmphasized: isEmphasized
        )
    }

    static func percent(
        id: String,
        label: String,
        amount: Decimal,
        isEmphasized: Bool = false
    ) -> CalculationLine {
        CalculationLine(
            id: id,
            label: label,
            amount: amount.percentRounded,
            text: nil,
            valueKind: .percent,
            isEmphasized: isEmphasized
        )
    }

    static func text(
        id: String,
        label: String,
        text: String,
        isEmphasized: Bool = false
    ) -> CalculationLine {
        CalculationLine(
            id: id,
            label: label,
            amount: nil,
            text: text,
            valueKind: .text,
            isEmphasized: isEmphasized
        )
    }
}

struct CalculationResult: Equatable, Codable {
    let mainAmount: Decimal
    let mainLabel: String
    let lines: [CalculationLine]
    let formula: String
    let warnings: [CalculationWarning]
    let sourceRuleSetId: String

    var copyText: String {
        let detail = lines.map { line in
            "\(line.label) : \(line.displayValue)"
        }.joined(separator: "\n")

        return "\(mainLabel) : \(mainAmount.currencyText)\n\(detail)\nFormule utilisée : \(formula)"
    }
}

struct VATBreakdown: Equatable {
    let htAmount: Decimal
    let vatAmount: Decimal
    let ttcAmount: Decimal
    let rate: Decimal
}

enum VATCalculator {
    static func fromHT(_ amount: Decimal, rate: Decimal) -> VATBreakdown {
        TaxCalculationEngine.vatFromHT(amount, rate: rate)
    }

    static func fromTTC(_ amount: Decimal, rate: Decimal) -> VATBreakdown {
        TaxCalculationEngine.vatFromTTC(amount, rate: rate)
    }
}

enum TaxCalculationEngine {
    static func calculate(
        _ input: CalculationInput,
        ruleSet: TaxRuleSet = .french2026
    ) -> CalculationResult {
        switch input {
        case .vat(let input):
            return calculateVAT(input, ruleSet: ruleSet)
        case .independent(let input):
            return calculateIndependent(input, ruleSet: ruleSet)
        case .netGoal(let input):
            return calculateNetGoal(input, ruleSet: ruleSet)
        case .margin(let input):
            return calculateMargin(input, ruleSet: ruleSet)
        }
    }

    static func vatFromHT(_ amount: Decimal, rate: Decimal) -> VATBreakdown {
        let vatAmount = amount * rate
        let ttcAmount = amount + vatAmount

        return VATBreakdown(
            htAmount: amount.currencyRounded,
            vatAmount: vatAmount.currencyRounded,
            ttcAmount: ttcAmount.currencyRounded,
            rate: rate
        )
    }

    static func vatFromTTC(_ amount: Decimal, rate: Decimal) -> VATBreakdown {
        let htAmount = amount / (1 + rate)
        let vatAmount = amount - htAmount

        return VATBreakdown(
            htAmount: htAmount.currencyRounded,
            vatAmount: vatAmount.currencyRounded,
            ttcAmount: amount.currencyRounded,
            rate: rate
        )
    }

    private static func calculateVAT(
        _ input: VATCalculationInput,
        ruleSet: TaxRuleSet
    ) -> CalculationResult {
        let breakdown: VATBreakdown
        let mainAmount: Decimal
        let mainLabel: String
        let formula: String

        switch input.kind {
        case .htToTTC:
            breakdown = vatFromHT(input.amount, rate: input.rate)
            mainAmount = breakdown.ttcAmount
            mainLabel = "TTC"
            formula = "HT × (1 + taux de TVA)"
        case .ttcToHT:
            breakdown = vatFromTTC(input.amount, rate: input.rate)
            mainAmount = breakdown.htAmount
            mainLabel = "HT"
            formula = "TTC ÷ (1 + taux de TVA)"
        case .vatOnly:
            breakdown = vatFromHT(input.amount, rate: input.rate)
            mainAmount = breakdown.vatAmount
            mainLabel = "TVA seule"
            formula = "HT × taux de TVA"
        }

        return CalculationResult(
            mainAmount: mainAmount.currencyRounded,
            mainLabel: mainLabel,
            lines: [
                .currency(id: "ht", label: "Montant HT", amount: breakdown.htAmount),
                .currency(id: "vat", label: "TVA à mettre de côté", amount: breakdown.vatAmount, isEmphasized: true),
                .currency(id: "ttc", label: "Montant TTC", amount: breakdown.ttcAmount),
                .text(id: "rate", label: "Taux utilisé", text: input.rate.percentText)
            ],
            formula: formula,
            warnings: [
                CalculationWarning(
                    id: "vat_scope",
                    message: "L'app ne choisit pas automatiquement le bon taux selon votre produit ou service."
                )
            ],
            sourceRuleSetId: ruleSet.id
        )
    }

    private static func calculateIndependent(
        _ input: IndependentCalculationInput,
        ruleSet: TaxRuleSet
    ) -> CalculationResult {
        let profile = ruleSet.microProfile(id: input.profileId)
        let normalized = normalizeRevenue(
            amount: input.amount,
            amountKind: input.amountKind,
            vatRate: input.vatRate,
            vatApplicable: input.vatApplicable
        )
        let socialContributions = normalized.ht * profile.socialContributionRate
        let vflIncomeTax = input.vflEnabled ? normalized.ht * profile.vflIncomeTaxRate : 0
        let cfpEstimate = normalized.ht * profile.cfpReserveRate
        let netBeforeIncomeTax = normalized.ht - socialContributions
        let netAfterVFL = netBeforeIncomeTax - vflIncomeTax
        let prudentReserve = normalized.vat
            + socialContributions
            + vflIncomeTax
            + (input.includeCFPInPrudentReserve ? cfpEstimate : 0)
        let mainAmount = input.vflEnabled ? netAfterVFL : netBeforeIncomeTax
        let mainLabel = "Il te reste environ"

        var lines: [CalculationLine] = [
            .currency(id: "ca_ht", label: "CAHT retenu pour les cotisations", amount: normalized.ht, isEmphasized: true)
        ]

        if input.vatApplicable {
            lines.append(.currency(id: "vat", label: "TVA à mettre de côté", amount: normalized.vat, isEmphasized: true))
        } else {
            lines.append(.text(id: "vat", label: "Franchise en base", text: "TVA non facturée"))
        }

        lines.append(contentsOf: [
            .currency(id: "social", label: "Cotisations sociales estimées", amount: socialContributions),
            input.vflEnabled
                ? .currency(id: "vfl", label: "Versement libératoire IR", amount: vflIncomeTax)
                : .text(id: "income_tax", label: "Impôt sur le revenu", text: "Hors impôt sur le revenu"),
            .currency(id: "cfp", label: "CFP annuelle indicative", amount: cfpEstimate),
            .currency(id: "reserve", label: "Montant à garder prudemment", amount: prudentReserve, isEmphasized: true),
            .text(id: "profile", label: "Profil", text: profile.label)
        ])

        return CalculationResult(
            mainAmount: mainAmount.currencyRounded,
            mainLabel: mainLabel,
            lines: lines,
            formula: "CAHT − cotisations sociales\(input.vflEnabled ? " − versement libératoire" : "")",
            warnings: warnings(
                caHT: normalized.ht,
                profile: profile,
                vatApplicable: input.vatApplicable,
                vflEnabled: input.vflEnabled
            ),
            sourceRuleSetId: ruleSet.id
        )
    }

    private static func calculateNetGoal(
        _ input: NetGoalCalculationInput,
        ruleSet: TaxRuleSet
    ) -> CalculationResult {
        let profile = ruleSet.microProfile(id: input.profileId)
        let vflRate = input.vflEnabled ? profile.vflIncomeTaxRate : 0
        let cfpRate = input.includeCFPInRequiredAmount ? profile.cfpReserveRate : 0
        let denominator = 1 - profile.socialContributionRate - vflRate - cfpRate
        let requiredHT = denominator > 0 ? input.targetNet / denominator : 0
        let requiredVAT = input.vatApplicable ? requiredHT * input.vatRate : 0
        let requiredTTC = requiredHT + requiredVAT
        let socialContributions = requiredHT * profile.socialContributionRate
        let vflIncomeTax = requiredHT * vflRate
        let cfpEstimate = requiredHT * cfpRate

        var lines: [CalculationLine] = [
            .currency(id: "target", label: "Objectif net", amount: input.targetNet, isEmphasized: true),
            .currency(id: "required_ht", label: "Montant HT à facturer", amount: requiredHT, isEmphasized: true)
        ]

        if input.vatApplicable {
            lines.append(.currency(id: "required_vat", label: "TVA à mettre de côté", amount: requiredVAT))
            lines.append(.currency(id: "required_ttc", label: "Montant TTC à facturer", amount: requiredTTC, isEmphasized: true))
        } else {
            lines.append(.text(id: "vat", label: "Franchise en base", text: "TVA non facturée"))
        }

        lines.append(contentsOf: [
            .currency(id: "social", label: "Cotisations sociales estimées", amount: socialContributions),
            input.vflEnabled
                ? .currency(id: "vfl", label: "Versement libératoire IR", amount: vflIncomeTax)
                : .text(id: "income_tax", label: "Impôt sur le revenu", text: "Hors impôt sur le revenu"),
            input.includeCFPInRequiredAmount
                ? .currency(id: "cfp", label: "CFP annuelle indicative incluse", amount: cfpEstimate)
                : .text(id: "cfp", label: "CFP annuelle indicative", text: profile.cfpLabel),
            .text(id: "profile", label: "Profil", text: profile.label)
        ])

        return CalculationResult(
            mainAmount: requiredHT.currencyRounded,
            mainLabel: "Tu dois facturer environ",
            lines: lines,
            formula: "Objectif net ÷ (1 − taux de cotisations\(input.vflEnabled ? " − versement libératoire" : "")\(input.includeCFPInRequiredAmount ? " − CFP" : ""))",
            warnings: warnings(
                caHT: requiredHT,
                profile: profile,
                vatApplicable: input.vatApplicable,
                vflEnabled: input.vflEnabled
            ),
            sourceRuleSetId: ruleSet.id
        )
    }

    private static func calculateMargin(
        _ input: MarginCalculationInput,
        ruleSet: TaxRuleSet
    ) -> CalculationResult {
        let purchaseHT = normalizeAmount(
            input.purchaseAmount,
            kind: input.purchaseKind,
            vatRate: input.vatRate,
            vatApplicable: input.vatApplicable
        )
        let saleHT = normalizeAmount(
            input.saleAmount,
            kind: input.saleKind,
            vatRate: input.vatRate,
            vatApplicable: input.vatApplicable
        )
        let grossMargin = saleHT - purchaseHT
        let marginRate = purchaseHT == 0 ? 0 : grossMargin / purchaseHT
        let markRate = saleHT == 0 ? 0 : grossMargin / saleHT
        let vatCollected = input.vatApplicable ? saleHT * input.vatRate : 0
        let vatDeductible = input.vatApplicable && input.vatDeductibleOnPurchase ? purchaseHT * input.vatRate : 0
        let netVAT = vatCollected - vatDeductible

        var warnings = prudenceWarnings
        if purchaseHT == 0 || saleHT == 0 {
            warnings.append(
                CalculationWarning(
                    id: "missing_margin_amount",
                    message: "Renseignez un achat et une vente pour obtenir des taux exploitables."
                )
            )
        }
        if !input.vatApplicable {
            warnings.append(
                CalculationWarning(
                    id: "franchise_margin",
                    message: "En franchise en base, la TVA n'est pas facturée et n'est pas déductible sur les achats."
                )
            )
        }

        return CalculationResult(
            mainAmount: grossMargin.currencyRounded,
            mainLabel: "Marge brute HT",
            lines: [
                .currency(id: "purchase_ht", label: "Achat HT", amount: purchaseHT),
                .currency(id: "sale_ht", label: "Vente HT", amount: saleHT),
                .currency(id: "gross_margin", label: "Marge brute HT", amount: grossMargin, isEmphasized: true),
                .percent(id: "margin_rate", label: "Taux de marge", amount: marginRate),
                .percent(id: "mark_rate", label: "Taux de marque", amount: markRate),
                .currency(id: "vat_collected", label: "TVA collectée", amount: vatCollected),
                .currency(id: "vat_deductible", label: "TVA déductible", amount: vatDeductible),
                .currency(id: "net_vat", label: "TVA nette", amount: netVAT, isEmphasized: true)
            ],
            formula: "Vente HT − Achat HT",
            warnings: warnings,
            sourceRuleSetId: ruleSet.id
        )
    }

    private static func normalizeRevenue(
        amount: Decimal,
        amountKind: AmountKind,
        vatRate: Decimal,
        vatApplicable: Bool
    ) -> (ht: Decimal, vat: Decimal, ttc: Decimal) {
        guard vatApplicable else {
            return (amount, 0, amount)
        }

        switch amountKind {
        case .ht:
            let vat = amount * vatRate
            return (amount, vat, amount + vat)
        case .ttc:
            let ht = amount / (1 + vatRate)
            return (ht, amount - ht, amount)
        }
    }

    private static func normalizeAmount(
        _ amount: Decimal,
        kind: AmountKind,
        vatRate: Decimal,
        vatApplicable: Bool
    ) -> Decimal {
        if kind == .ttc && vatApplicable {
            return amount / (1 + vatRate)
        }

        return amount
    }

    private static func warnings(
        caHT: Decimal,
        profile: TaxProfile,
        vatApplicable: Bool,
        vflEnabled: Bool
    ) -> [CalculationWarning] {
        var warnings = prudenceWarnings

        if caHT > profile.microThreshold {
            warnings.append(
                CalculationWarning(
                    id: "micro_threshold",
                    message: "Le montant dépasse le seuil annuel micro du profil. Ce cas est hors scope V1."
                )
            )
        } else if caHT > profile.vatFranchiseMajorThreshold && !vatApplicable {
            warnings.append(
                CalculationWarning(
                    id: "vat_franchise_major",
                    message: "Le seuil majoré de franchise TVA est dépassé pour ce profil."
                )
            )
        } else if caHT > profile.vatFranchiseBaseThreshold && !vatApplicable {
            warnings.append(
                CalculationWarning(
                    id: "vat_franchise_base",
                    message: "Le seuil de base de franchise TVA est dépassé. La TVA peut s'appliquer l'année suivante."
                )
            )
        }

        if vflEnabled {
            warnings.append(
                CalculationWarning(
                    id: "vfl_conditions",
                    message: "Le versement libératoire est une option soumise à conditions."
                )
            )
        } else {
            warnings.append(
                CalculationWarning(
                    id: "income_tax_scope",
                    message: "Le barème progressif de l'impôt sur le revenu n'est pas calculé en V1."
                )
            )
        }

        profile.warnings.enumerated().forEach { index, message in
            warnings.append(CalculationWarning(id: "profile_\(index)", message: message))
        }

        return warnings
    }

    private static let prudenceWarnings = [
        CalculationWarning(
            id: "prudence",
            message: "Ce résultat est une estimation indicative, pas une déclaration officielle."
        )
    ]
}

extension CalculationLine {
    var displayValue: String {
        switch valueKind {
        case .currency:
            return (amount ?? 0).currencyText
        case .percent:
            return (amount ?? 0).percentText
        case .text:
            return text ?? ""
        }
    }
}

extension Decimal {
    static func fixed(_ value: String) -> Decimal {
        Decimal(string: value, locale: Locale(identifier: "en_US_POSIX")) ?? 0
    }

    var currencyRounded: Decimal {
        rounded(scale: 2)
    }

    var percentRounded: Decimal {
        rounded(scale: 4)
    }

    var currencyText: String {
        FormatterFactory.currency.string(from: self as NSDecimalNumber) ?? "\(self)"
    }

    var decimalText: String {
        FormatterFactory.decimal.string(from: self as NSDecimalNumber) ?? "\(self)"
    }

    var percentText: String {
        FormatterFactory.percent.string(from: self as NSDecimalNumber) ?? "\(self)"
    }

    func rounded(scale: Int) -> Decimal {
        var source = self
        var result = Decimal()
        NSDecimalRound(&result, &source, scale, .plain)
        return result
    }
}

private enum FormatterFactory {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static let decimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static let percent: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
