//
//  DefaultReceiptRepository.swift
//  SnapReceipt
//
//  Created by Pekomon on 9.5.2026.
//

import Foundation

struct DefaultReceiptRepository: ReceiptRepository {
    private let receiptStore: any ReceiptStoring

    nonisolated init(receiptStore: any ReceiptStoring) {
        self.receiptStore = receiptStore
    }

    nonisolated func fetchReceipts() async throws -> [Receipt] {
        try receiptStore
            .loadReceipts()
            .sorted { $0.metadata.updatedAt > $1.metadata.updatedAt }
    }

    nonisolated func fetchReceipt(id: Receipt.ID) async throws -> Receipt {
        let receipts = try receiptStore.loadReceipts()

        guard let receipt = receipts.first(where: { $0.metadata.id == id }) else {
            throw ReceiptRepositoryError.receiptNotFound(id)
        }

        return receipt
    }

    nonisolated func saveReceipt(_ receipt: Receipt) async throws {
        var receipts = try receiptStore.loadReceipts()

        if let index = receipts.firstIndex(where: { $0.metadata.id == receipt.metadata.id }) {
            receipts[index] = receipt
        } else {
            receipts.append(receipt)
        }

        try receiptStore.saveReceipts(receipts)
    }

    nonisolated func deleteReceipt(id: Receipt.ID) async throws {
        var receipts = try receiptStore.loadReceipts()

        guard let index = receipts.firstIndex(where: { $0.metadata.id == id }) else {
            throw ReceiptRepositoryError.receiptNotFound(id)
        }

        receipts.remove(at: index)
        try receiptStore.saveReceipts(receipts)
    }
}
