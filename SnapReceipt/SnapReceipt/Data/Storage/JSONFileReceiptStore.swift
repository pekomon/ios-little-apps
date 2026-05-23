//
//  JSONFileReceiptStore.swift
//  SnapReceipt
//
//  Created by Pekomon on 9.5.2026.
//

import Foundation

protocol ReceiptStoring: Sendable {
    nonisolated func loadReceipts() throws -> [Receipt]
    nonisolated func saveReceipts(_ receipts: [Receipt]) throws
}

struct ReceiptPersistenceLocation: Sendable {
    let directoryURL: URL
    let receiptsFileURL: URL
    let imagesDirectoryURL: URL

    nonisolated init(fileManager: FileManager = .default) {
        let baseDirectory =
            fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ??
            fileManager.temporaryDirectory

        self.init(baseDirectoryURL: baseDirectory)
    }

    nonisolated init(baseDirectoryURL: URL, appDirectoryName: String = "SnapReceipt") {
        let directoryURL = baseDirectoryURL.appendingPathComponent(appDirectoryName, isDirectory: true)
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
    nonisolated(unsafe) private let fileManager: FileManager
    private let persistenceLocation: ReceiptPersistenceLocation
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    nonisolated init(
        fileManager: FileManager = .default,
        persistenceLocation: ReceiptPersistenceLocation = ReceiptPersistenceLocation()
    ) {
        self.fileManager = fileManager
        self.persistenceLocation = persistenceLocation
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder.dateDecodingStrategy = .iso8601
    }

    nonisolated func loadReceipts() throws -> [Receipt] {
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

    nonisolated func saveReceipts(_ receipts: [Receipt]) throws {
        try fileManager.createDirectory(
            at: persistenceLocation.directoryURL,
            withIntermediateDirectories: true
        )

        let data = try encoder.encode(receipts)
        try data.write(to: persistenceLocation.receiptsFileURL, options: .atomic)
    }
}
