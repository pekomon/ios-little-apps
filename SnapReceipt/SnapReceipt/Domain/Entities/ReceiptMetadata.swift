//
//  ReceiptMetadata.swift
//  SnapReceipt
//
//  Created by Pekomon on 7.5.2026.
//

import Foundation

struct ReceiptMetadata: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    let merchantName: String
    let purchaseDate: Date?
    let totalAmount: Decimal?
    let currencyCode: String?
    let source: ReceiptSource
    let createdAt: Date
    let updatedAt: Date

    init(
        id: UUID = UUID(),
        merchantName: String,
        purchaseDate: Date? = nil,
        totalAmount: Decimal? = nil,
        currencyCode: String? = nil,
        source: ReceiptSource,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.merchantName = merchantName
        self.purchaseDate = purchaseDate
        self.totalAmount = totalAmount
        self.currencyCode = currencyCode
        self.source = source
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    func updatingTimestamp(_ date: Date = .now) -> ReceiptMetadata {
        ReceiptMetadata(
            id: id,
            merchantName: merchantName,
            purchaseDate: purchaseDate,
            totalAmount: totalAmount,
            currencyCode: currencyCode,
            source: source,
            createdAt: createdAt,
            updatedAt: date
        )
    }
}

enum ReceiptSource: String, Hashable, Codable, CaseIterable, Sendable {
    case camera
    case photoLibrary
    case fileImport

    var displayName: String {
        switch self {
        case .camera:
            "Camera Capture"
        case .photoLibrary:
            "Photo Library"
        case .fileImport:
            "Files Import"
        }
    }
}
