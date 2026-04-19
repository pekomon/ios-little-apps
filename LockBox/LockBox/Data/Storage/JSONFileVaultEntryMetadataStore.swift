//
//  JSONFileVaultEntryMetadataStore.swift
//  LockBox
//
//  Created by Pekomon on 19.4.2026.
//

import Foundation

struct VaultPersistenceLocation: Sendable {
    let directoryURL: URL
    let metadataFileURL: URL

    init(fileManager: FileManager = .default) {
        let baseDirectory =
            fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ??
            fileManager.temporaryDirectory

        let directoryURL = baseDirectory.appendingPathComponent("LockBox", isDirectory: true)
        self.directoryURL = directoryURL
        self.metadataFileURL = directoryURL.appendingPathComponent("vault-metadata.json")
    }
}

enum VaultPersistenceError: LocalizedError, Equatable {
    case invalidMetadataData

    var errorDescription: String? {
        switch self {
        case .invalidMetadataData:
            return "Local vault metadata could not be decoded."
        }
    }
}

struct JSONFileVaultEntryMetadataStore: VaultEntryMetadataStoring {
    private let fileManager: FileManager
    private let persistenceLocation: VaultPersistenceLocation
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        fileManager: FileManager = .default,
        persistenceLocation: VaultPersistenceLocation = VaultPersistenceLocation()
    ) {
        self.fileManager = fileManager
        self.persistenceLocation = persistenceLocation
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func loadMetadataRecords() throws -> [VaultEntryMetadataRecord] {
        let url = persistenceLocation.metadataFileURL

        guard fileManager.fileExists(atPath: url.path) else {
            return []
        }

        let data = try Data(contentsOf: url)

        do {
            return try decoder.decode([VaultEntryMetadataRecord].self, from: data)
        } catch {
            throw VaultPersistenceError.invalidMetadataData
        }
    }

    func saveMetadataRecords(_ records: [VaultEntryMetadataRecord]) throws {
        try fileManager.createDirectory(
            at: persistenceLocation.directoryURL,
            withIntermediateDirectories: true
        )

        let data = try encoder.encode(records)
        try data.write(to: persistenceLocation.metadataFileURL, options: .atomic)
    }
}
