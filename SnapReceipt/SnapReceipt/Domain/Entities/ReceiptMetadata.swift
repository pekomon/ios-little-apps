//
//  ReceiptMetadata.swift
//  SnapReceipt
//
//  Created by Pekomon on 7.5.2026.
//

import Foundation

struct ReceiptMetadata: Identifiable, Hashable, Codable, Sendable {
    nonisolated let id: UUID
    nonisolated let merchantName: String
    nonisolated let purchaseDate: Date?
    nonisolated let totalAmount: Decimal?
    nonisolated let currencyCode: String?
    nonisolated let source: ReceiptSource
    nonisolated let createdAt: Date
    nonisolated let updatedAt: Date

    nonisolated init(
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

    nonisolated func updatingTimestamp(_ date: Date = .now) -> ReceiptMetadata {
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

    nonisolated var displayName: String {
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
