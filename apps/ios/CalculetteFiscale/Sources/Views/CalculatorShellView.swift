import SwiftUI

struct CalculatorShellView: View {
    private let modes = ["TVA", "Independant", "Net", "Marge"]
    private let keypadRows = [
        ["7", "8", "9", "+TVA"],
        ["4", "5", "6", "-TVA"],
        ["1", "2", "3", "%"],
        ["0", ",", "⌫", "="]
    ]

    @State private var selectedMode = "TVA"
    @State private var displayValue = "0"

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 18) {
                modeSelector
                Spacer(minLength: 16)
                resultArea
                keypad
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 24)
        }
    }

    private var modeSelector: some View {
        HStack(spacing: 8) {
            ForEach(modes, id: \.self) { mode in
                Button {
                    selectedMode = mode
                } label: {
                    Text(mode)
                        .font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedMode == mode ? Color.white : Color.white.opacity(0.12))
                        .foregroundStyle(selectedMode == mode ? Color.black : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .accessibilityLabel("Mode \(mode)")
            }
        }
    }

    private var resultArea: some View {
        VStack(alignment: .trailing, spacing: 10) {
            Text(selectedMode)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.58))

            Text(displayValue)
                .font(.system(size: 72, weight: .light, design: .rounded))
                .minimumScaleFactor(0.45)
                .lineLimit(1)
                .foregroundStyle(.white)

            Text("TVA 20 % active")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var keypad: some View {
        VStack(spacing: 10) {
            ForEach(keypadRows, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { value in
                        Button {
                            handleTap(value)
                        } label: {
                            Text(value)
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .frame(height: 68)
                                .background(buttonColor(for: value))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .accessibilityLabel("Touche \(value)")
                    }
                }
            }
        }
    }

    private func buttonColor(for value: String) -> Color {
        if value == "=" || value.contains("TVA") {
            return Color.orange
        }

        if value == "%" || value == "⌫" {
            return Color.white.opacity(0.22)
        }

        return Color.white.opacity(0.14)
    }

    private func handleTap(_ value: String) {
        switch value {
        case "⌫":
            displayValue = displayValue.count > 1 ? String(displayValue.dropLast()) : "0"
        case "=":
            displayValue = displayValue
        case ",":
            if !displayValue.contains(",") {
                displayValue += ","
            }
        case "+TVA":
            displayValue = applyVAT(add: true)
        case "-TVA":
            displayValue = applyVAT(add: false)
        default:
            displayValue = displayValue == "0" ? value : displayValue + value
        }
    }

    private func applyVAT(add: Bool) -> String {
        let normalized = displayValue.replacingOccurrences(of: ",", with: ".")
        guard let decimal = Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX")) else {
            return displayValue
        }

        let breakdown = add
            ? VATCalculator.fromHT(decimal, rate: Decimal(string: "0.20") ?? 0.20)
            : VATCalculator.fromTTC(decimal, rate: Decimal(string: "0.20") ?? 0.20)

        let result = add ? breakdown.ttcAmount : breakdown.htAmount
        return Self.currencyFormatter.string(from: result as NSDecimalNumber) ?? displayValue
    }

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

#Preview {
    CalculatorShellView()
}
