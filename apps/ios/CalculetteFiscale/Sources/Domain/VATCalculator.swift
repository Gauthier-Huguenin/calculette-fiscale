import Foundation

struct VATBreakdown: Equatable {
    let htAmount: Decimal
    let vatAmount: Decimal
    let ttcAmount: Decimal
    let rate: Decimal
}

enum VATCalculator {
    static func fromHT(_ amount: Decimal, rate: Decimal) -> VATBreakdown {
        let vatAmount = amount * rate
        let ttcAmount = amount + vatAmount

        return VATBreakdown(
            htAmount: roundedCurrency(amount),
            vatAmount: roundedCurrency(vatAmount),
            ttcAmount: roundedCurrency(ttcAmount),
            rate: rate
        )
    }

    static func fromTTC(_ amount: Decimal, rate: Decimal) -> VATBreakdown {
        let divisor = Decimal(1) + rate
        let htAmount = amount / divisor
        let vatAmount = amount - htAmount

        return VATBreakdown(
            htAmount: roundedCurrency(htAmount),
            vatAmount: roundedCurrency(vatAmount),
            ttcAmount: roundedCurrency(amount),
            rate: rate
        )
    }

    private static func roundedCurrency(_ value: Decimal) -> Decimal {
        var source = value
        var result = Decimal()
        NSDecimalRound(&result, &source, 2, .plain)
        return result
    }
}
