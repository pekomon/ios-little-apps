//
//  ReceiptRepository.swift
//  SnapReceipt
//
//  Created by Pekomon on 7.5.2026.
//

import Foundation

protocol ReceiptRepository: Sendable {
    func fetchReceipts() async throws -> [Receipt]
    func fetchReceipt(id: Receipt.ID) async throws -> Receipt
    func saveReceipt(_ receipt: Receipt) async throws
    func deleteReceipt(id: Receipt.ID) async throws
}

enum ReceiptRepositoryError: LocalizedError, Equatable, Sendable {
    case receiptNotFound(Receipt.ID)

    var errorDescription: String? {
        switch self {
        case .receiptNotFound:
            "The requested receipt could not be found."
        }
    }
}
