//
//  ReceiptParsingService.swift
//  SnapReceipt
//
//  Created by Pekomon on 8.5.2026.
//

import Foundation

protocol ReceiptParsingServicing: Sendable {
    func parseReceiptDetails(from ocrResult: ReceiptOCRResult) -> ParsedReceiptDetails
}

struct ReceiptParsingService: ReceiptParsingServicing, Sendable {
    private static let dateDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
    private static let amountPattern = /(?i)(eur|usd|gbp|sek|nok|dkk|cad|aud|€|\$|£)?\s*([0-9]{1,4}(?:[.,\s][0-9]{3})*(?:[.,][0-9]{2}))/ 

    nonisolated func parseReceiptDetails(from ocrResult: ReceiptOCRResult) -> ParsedReceiptDetails {
        let lines = ocrResult.lines

        return ParsedReceiptDetails(
            merchantName: merchantName(from: lines),
            purchaseDate: purchaseDate(from: ocrResult.rawText),
            totalAmount: totalAmount(from: lines),
            currencyCode: currencyCode(from: lines)
        )
    }

    private func merchantName(from lines: [String]) -> String? {
        lines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { line in
                guard !line.isEmpty else {
                    return false
                }

                let digitRatio = Double(line.filter(\.isNumber).count) / Double(max(line.count, 1))
                return digitRatio < 0.25 && line.count > 2
            }
    }

    private func purchaseDate(from text: String) -> Date? {
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return Self.dateDetector?.matches(in: text, options: [], range: range).first?.date
    }

    private func totalAmount(from lines: [String]) -> Decimal? {
        let candidateLines = lines.reversed().filter { line in
            let lowered = line.lowercased()
            return lowered.contains("total") || lowered.contains("sum") || lowered.contains("amount") || lowered.contains("visa") == false
        }

        for line in candidateLines {
            if let amount = decimalAmount(from: line) {
                return amount
            }
        }

        for line in lines.reversed() {
            if let amount = decimalAmount(from: line) {
                return amount
            }
        }

        return nil
    }

    private func currencyCode(from lines: [String]) -> String? {
        for line in lines {
            let lowered = line.lowercased()
            if lowered.contains("eur") || line.contains("€") {
                return "EUR"
            }
            if lowered.contains("usd") || line.contains("$") {
                return "USD"
            }
            if lowered.contains("gbp") || line.contains("£") {
                return "GBP"
            }
            if lowered.contains("sek") {
                return "SEK"
            }
            if lowered.contains("nok") {
                return "NOK"
            }
            if lowered.contains("dkk") {
                return "DKK"
            }
        }

        return nil
    }

    private func decimalAmount(from line: String) -> Decimal? {
        guard let match = line.firstMatch(of: Self.amountPattern) else {
            return nil
        }

        let rawValue = String(match.output.2)
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")

        return Decimal(string: rawValue, locale: Locale(identifier: "en_US_POSIX"))
    }
}

struct ParsedReceiptDetails: Hashable, Sendable {
    let merchantName: String?
    let purchaseDate: Date?
    let totalAmount: Decimal?
    let currencyCode: String?
}
