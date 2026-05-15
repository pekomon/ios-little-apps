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
            receipts = try await repository.fetchReceipts()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func saveReceipt(_ receipt: Receipt, imageData: Data? = nil) async throws {
        var receiptToSave = receipt

        if let imageData {
            let imageFileName = try imageStore.saveImageData(imageData, for: receipt.id)
            receiptToSave = receipt.updating(imageFileName: imageFileName)
        }

        try await repository.saveReceipt(receiptToSave)
        receipts = try await repository.fetchReceipts()
        errorMessage = nil
    }
}
