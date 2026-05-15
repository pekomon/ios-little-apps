//
//  ReceiptReviewDraft.swift
//  SnapReceipt
//
//  Created by Pekomon on 15.5.2026.
//

import Foundation

struct ReceiptReviewDraft: Sendable {
    var merchantName: String
    var purchaseDate: Date
    var includesPurchaseDate: Bool
    var totalAmountText: String
    var currencyCode: String
    var notes: String
    var rawText: String
    let source: ReceiptSource

    var trimmedMerchantName: String {
        merchantName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var normalizedCurrencyCode: String? {
        let code = currencyCode.trimmingCharacters(in: .whitespacesAndNewlines)
        return code.isEmpty ? nil : code.uppercased()
    }

    var parsedTotalAmount: Decimal? {
        let sanitizedAmount = totalAmountText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard !sanitizedAmount.isEmpty else {
            return nil
        }

        return Decimal(string: sanitizedAmount, locale: Locale(identifier: "en_US_POSIX"))
    }

    var resolvedPurchaseDate: Date? {
        includesPurchaseDate ? purchaseDate : nil
    }
}
