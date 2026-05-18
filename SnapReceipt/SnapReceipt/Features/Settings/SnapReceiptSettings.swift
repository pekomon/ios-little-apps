//
//  SnapReceiptSettings.swift
//  SnapReceipt
//
//  Created by Codex on 18.5.2026.
//

import Foundation

enum ReceiptImageQuality: String, CaseIterable, Identifiable {
    case compact
    case balanced
    case high

    var id: String { rawValue }

    var title: String {
        switch self {
        case .compact:
            "Compact"
        case .balanced:
            "Balanced"
        case .high:
            "High"
        }
    }

    var detail: String {
        switch self {
        case .compact:
            "Smaller saved images with more compression."
        case .balanced:
            "Good tradeoff between OCR clarity and storage size."
        case .high:
            "Sharper saved images with less compression."
        }
    }

    var compressionQuality: CGFloat {
        switch self {
        case .compact:
            0.65
        case .balanced:
            0.82
        case .high:
            0.92
        }
    }
}

enum SnapReceiptSettings {
    static let defaultCurrencyKey = "snapreceipt.settings.defaultCurrency"
    static let imageQualityKey = "snapreceipt.settings.imageQuality"

    static let supportedCurrencies = [
        "EUR",
        "USD",
        "GBP",
        "SEK",
        "NOK",
        "DKK",
        "CAD",
        "AUD"
    ]

    static func defaultCurrency(userDefaults: UserDefaults = .standard) -> String {
        let storedValue = userDefaults.string(forKey: defaultCurrencyKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()

        if let storedValue, supportedCurrencies.contains(storedValue) {
            return storedValue
        }

        if let localeCurrency = Locale.current.currency?.identifier,
           supportedCurrencies.contains(localeCurrency) {
            return localeCurrency
        }

        return "EUR"
    }

    static func imageQuality(userDefaults: UserDefaults = .standard) -> ReceiptImageQuality {
        guard
            let rawValue = userDefaults.string(forKey: imageQualityKey),
            let quality = ReceiptImageQuality(rawValue: rawValue)
        else {
            return .balanced
        }

        return quality
    }
}
