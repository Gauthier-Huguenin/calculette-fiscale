import XCTest
@testable import CalculetteFiscale

final class VATCalculatorTests: XCTestCase {
    func testHTToTTCAtTwentyPercent() {
        let result = VATCalculator.fromHT(100, rate: 0.20)

        XCTAssertEqual(result.htAmount, 100)
        XCTAssertEqual(result.vatAmount, 20)
        XCTAssertEqual(result.ttcAmount, 120)
    }

    func testTTCToHTAtTwentyPercent() {
        let result = VATCalculator.fromTTC(120, rate: 0.20)

        XCTAssertEqual(result.htAmount, 100)
        XCTAssertEqual(result.vatAmount, 20)
        XCTAssertEqual(result.ttcAmount, 120)
    }

    func testHTToTTCAtReducedRate() {
        let result = VATCalculator.fromHT(100, rate: 0.055)

        XCTAssertEqual(result.htAmount, 100)
        XCTAssertEqual(result.vatAmount, 5.50)
        XCTAssertEqual(result.ttcAmount, 105.50)
    }
}
