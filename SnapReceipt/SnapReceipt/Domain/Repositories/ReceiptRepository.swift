//
//  ReceiptRepository.swift
//  SnapReceipt
//
//  Created by Pekomon on 7.5.2026.
//

import Foundation

protocol ReceiptRepository: Sendable {
    nonisolated func fetchReceipts() async throws -> [Receipt]
    nonisolated func fetchReceipt(id: Receipt.ID) async throws -> Receipt
    nonisolated func saveReceipt(_ receipt: Receipt) async throws
    nonisolated func deleteReceipt(id: Receipt.ID) async throws
}

enum ReceiptRepositoryError: LocalizedError, Equatable, Sendable {
    case receiptNotFound(Receipt.ID)

    nonisolated var errorDescription: String? {
        switch self {
        case .receiptNotFound:
            "The requested receipt could not be found."
        }
    }
}
