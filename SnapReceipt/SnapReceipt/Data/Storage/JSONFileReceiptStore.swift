//
//  JSONFileReceiptStore.swift
//  SnapReceipt
//
//  Created by Pekomon on 9.5.2026.
//

import Foundation

protocol ReceiptStoring: Sendable {
    func loadReceipts() throws -> [Receipt]
    func saveReceipts(_ receipts: [Receipt]) throws
}

struct ReceiptPersistenceLocation: Sendable {
    let directoryURL: URL
    let receiptsFileURL: URL
    let imagesDirectoryURL: URL

    init(fileManager: FileManager = .default) {
        let baseDirectory =
            fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ??
            fileManager.temporaryDirectory

        let directoryURL = baseDirectory.appendingPathComponent("SnapReceipt", isDirectory: true)
        self.directoryURL = directoryURL
        self.receiptsFileURL = directoryURL.appendingPathComponent("receipts.json")
        self.imagesDirectoryURL = directoryURL.appendingPathComponent("ReceiptImages", isDirectory: true)
    }
}

enum ReceiptPersistenceError: LocalizedError, Equatable {
    case invalidReceiptData

    var errorDescription: String? {
        switch self {
        case .invalidReceiptData:
            "Saved receipt data could not be decoded."
        }
    }
}

struct JSONFileReceiptStore: ReceiptStoring {
    private let fileManager: FileManager
    private let persistenceLocation: ReceiptPersistenceLocation
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        fileManager: FileManager = .default,
        persistenceLocation: ReceiptPersistenceLocation = ReceiptPersistenceLocation()
    ) {
        self.fileManager = fileManager
        self.persistenceLocation = persistenceLocation
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder.dateDecodingStrategy = .iso8601
    }

    func loadReceipts() throws -> [Receipt] {
        let url = persistenceLocation.receiptsFileURL

        guard fileManager.fileExists(atPath: url.path) else {
            return []
        }

        let data = try Data(contentsOf: url)

        do {
            return try decoder.decode([Receipt].self, from: data)
        } catch {
            throw ReceiptPersistenceError.invalidReceiptData
        }
    }

    func saveReceipts(_ receipts: [Receipt]) throws {
        try fileManager.createDirectory(
            at: persistenceLocation.directoryURL,
            withIntermediateDirectories: true
        )

        let data = try encoder.encode(receipts)
        try data.write(to: persistenceLocation.receiptsFileURL, options: .atomic)
    }
}
