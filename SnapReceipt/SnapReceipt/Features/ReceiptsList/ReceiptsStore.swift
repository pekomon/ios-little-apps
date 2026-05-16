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
    private let imageStore: any ReceiptImageStoring

    var receipts: [Receipt] = []
    var isLoading = false
    var errorMessage: String?

    init(
        repository: any ReceiptRepository,
        imageStore: any ReceiptImageStoring
    ) {
        self.repository = repository
        self.imageStore = imageStore
    }

    func loadReceipts() async {
        isLoading = true
        errorMessage = nil

        do {
            let repository = self.repository
            receipts = try await Task.detached(priority: .userInitiated) {
                try await repository.fetchReceipts()
            }.value
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func saveReceipt(_ receipt: Receipt, imageData: Data? = nil) async throws {
        let repository = self.repository
        let imageStore = self.imageStore

        let updatedReceipts = try await Task.detached(priority: .userInitiated) {
            var receiptToSave = receipt

            if let imageData {
                let imageFileName = try imageStore.saveImageData(imageData, for: receipt.id)
                receiptToSave = receipt.updating(imageFileName: imageFileName)
            }

            try await repository.saveReceipt(receiptToSave)
            return try await repository.fetchReceipts()
        }.value

        receipts = updatedReceipts
        errorMessage = nil
    }

    func deleteReceipt(_ receipt: Receipt) async throws {
        let previousReceipts = receipts
        receipts.removeAll { $0.id == receipt.id }
        errorMessage = nil

        let repository = self.repository
        let imageStore = self.imageStore

        do {
            let updatedReceipts = try await Task.detached(priority: .userInitiated) {
                try await repository.deleteReceipt(id: receipt.id)

                if let imageFileName = receipt.imageFileName {
                    try imageStore.deleteImage(named: imageFileName)
                }

                return try await repository.fetchReceipts()
            }.value

            receipts = updatedReceipts
            errorMessage = nil
        } catch {
            receipts = previousReceipts
            errorMessage = error.localizedDescription
            throw error
        }
    }
}
