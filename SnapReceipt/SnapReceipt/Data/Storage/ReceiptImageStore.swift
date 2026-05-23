//
//  ReceiptImageStore.swift
//  SnapReceipt
//
//  Created by Pekomon on 15.5.2026.
//

import Foundation

protocol ReceiptImageStoring: Sendable {
    nonisolated func saveImageData(_ data: Data, for receiptID: UUID) throws -> String
    nonisolated func imageURL(for fileName: String) -> URL
    nonisolated func deleteImage(named fileName: String) throws
}

struct ReceiptImageStore: ReceiptImageStoring {
    nonisolated(unsafe) private let fileManager: FileManager
    private let persistenceLocation: ReceiptPersistenceLocation

    nonisolated init(
        fileManager: FileManager = .default,
        persistenceLocation: ReceiptPersistenceLocation = ReceiptPersistenceLocation()
    ) {
        self.fileManager = fileManager
        self.persistenceLocation = persistenceLocation
    }

    nonisolated func saveImageData(_ data: Data, for receiptID: UUID) throws -> String {
        try fileManager.createDirectory(
            at: persistenceLocation.imagesDirectoryURL,
            withIntermediateDirectories: true
        )

        let fileName = "receipt-\(receiptID.uuidString.lowercased()).jpg"
        let destinationURL = persistenceLocation.imagesDirectoryURL.appendingPathComponent(fileName)
        try data.write(to: destinationURL, options: .atomic)
        return fileName
    }

    nonisolated func imageURL(for fileName: String) -> URL {
        persistenceLocation.imagesDirectoryURL.appendingPathComponent(fileName)
    }

    nonisolated func deleteImage(named fileName: String) throws {
        let imageURL = imageURL(for: fileName)

        guard fileManager.fileExists(atPath: imageURL.path) else {
            return
        }

        try fileManager.removeItem(at: imageURL)
    }
}
