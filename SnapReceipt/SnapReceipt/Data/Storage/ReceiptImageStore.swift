//
//  ReceiptImageStore.swift
//  SnapReceipt
//
//  Created by Pekomon on 15.5.2026.
//

import Foundation

protocol ReceiptImageStoring: Sendable {
    func saveImageData(_ data: Data, for receiptID: UUID) throws -> String
    func imageURL(for fileName: String) -> URL
}

struct ReceiptImageStore: ReceiptImageStoring {
    private let fileManager: FileManager
    private let persistenceLocation: ReceiptPersistenceLocation

    init(
        fileManager: FileManager = .default,
        persistenceLocation: ReceiptPersistenceLocation = ReceiptPersistenceLocation()
    ) {
        self.fileManager = fileManager
        self.persistenceLocation = persistenceLocation
    }

    func saveImageData(_ data: Data, for receiptID: UUID) throws -> String {
        try fileManager.createDirectory(
            at: persistenceLocation.imagesDirectoryURL,
            withIntermediateDirectories: true
        )

        let fileName = "receipt-\(receiptID.uuidString.lowercased()).jpg"
        let destinationURL = persistenceLocation.imagesDirectoryURL.appendingPathComponent(fileName)
        try data.write(to: destinationURL, options: .atomic)
        return fileName
    }

    func imageURL(for fileName: String) -> URL {
        persistenceLocation.imagesDirectoryURL.appendingPathComponent(fileName)
    }
}
