//
//  ReceiptParsingServiceTests.swift
//  SnapReceiptTests
//
//  Created by Codex on 23.5.2026.
//

import Foundation
import Testing
@testable import SnapReceipt

struct ReceiptParsingServiceTests {

    @Test
    func parseReceiptDetailsExtractsMerchantDateTotalAndCurrency() {
        let service = ReceiptParsingService()
        let ocrResult = ReceiptOCRResult(
            lines: [
                "Cafe Esplanad",
                "Lunch Menu",
                "Table 14",
                "Total EUR 18.40",
                "May 15, 2026"
            ],
            rawText: """
            Cafe Esplanad
            Lunch Menu
            Table 14
            Total EUR 18.40
            May 15, 2026
            """
        )

        let parsed = service.parseReceiptDetails(from: ocrResult)

        #expect(parsed.merchantName == "Cafe Esplanad")
        #expect(parsed.totalAmount == Decimal(string: "18.40"))
        #expect(parsed.currencyCode == "EUR")

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: parsed.purchaseDate ?? .distantPast)
        #expect(components.year == 2026)
        #expect(components.month == 5)
        #expect(components.day == 15)
    }

    @Test
    func parseReceiptDetailsFallsBackToLastDetectedAmount() {
        let service = ReceiptParsingService()
        let ocrResult = ReceiptOCRResult(
            lines: [
                "MARKET HALL",
                "APPLES 4.25",
                "CARD VISA",
                "AUTH 98122",
                "19.75"
            ],
            rawText: """
            MARKET HALL
            APPLES 4.25
            CARD VISA
            AUTH 98122
            19.75
            """
        )

        let parsed = service.parseReceiptDetails(from: ocrResult)

        #expect(parsed.merchantName == "MARKET HALL")
        #expect(parsed.totalAmount == Decimal(string: "19.75"))
    }
}
