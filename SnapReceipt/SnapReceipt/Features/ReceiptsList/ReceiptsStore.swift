//
//  ReceiptsStore.swift
//  SnapReceipt
//
//  Created by Pekomon on 9.5.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class ReceiptsStore {
    private let repository: any ReceiptRepository

    var receipts: [Receipt] = []
    var isLoading = false
    var errorMessage: String?

    init(repository: any ReceiptRepository) {
        self.repository = repository
    }

    func loadReceipts() async {
        isLoading = true
        errorMessage = nil

        do {
            receipts = try await repository.fetchReceipts()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func saveReceipt(_ receipt: Receipt) async throws {
        try await repository.saveReceipt(receipt)
        receipts = try await repository.fetchReceipts()
        errorMessage = nil
    }
}
