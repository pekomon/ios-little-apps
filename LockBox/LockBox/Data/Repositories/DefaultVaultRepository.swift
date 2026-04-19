//
//  DefaultVaultRepository.swift
//  LockBox
//
//  Created by Pekomon on 19.4.2026.
//

import Foundation

struct DefaultVaultRepository: VaultRepository {
    private let metadataStore: any VaultEntryMetadataStoring
    private let secureValueStore: any SecureValueStoring
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        metadataStore: any VaultEntryMetadataStoring,
        secureValueStore: any SecureValueStoring
    ) {
        self.metadataStore = metadataStore
        self.secureValueStore = secureValueStore
    }

    func fetchEntries() async throws -> [VaultEntry] {
        let records = try metadataStore.loadMetadataRecords()

        return try records
            .sorted { $0.updatedAt > $1.updatedAt }
            .map(entry(for:))
    }

    func fetchEntry(id: VaultEntry.ID) async throws -> VaultEntry {
        let records = try metadataStore.loadMetadataRecords()

        guard let record = records.first(where: { $0.id == id }) else {
            throw VaultRepositoryError.entryNotFound(id)
        }

        return try entry(for: record)
    }

    func saveEntry(_ entry: VaultEntry) async throws {
        var records = try metadataStore.loadMetadataRecords()
        let record = VaultEntryMetadataRecord(metadata: entry.metadata)
        let payload = VaultEntrySecretPayload(fields: entry.fields, notes: entry.notes)

        let encodedPayload = try encoder.encode(payload)
        try secureValueStore.saveValue(encodedPayload, for: secureKey(for: entry.id))

        if let index = records.firstIndex(where: { $0.id == entry.id }) {
            records[index] = record
        } else {
            records.append(record)
        }

        try metadataStore.saveMetadataRecords(records)
    }

    func deleteEntry(id: VaultEntry.ID) async throws {
        var records = try metadataStore.loadMetadataRecords()

        guard let index = records.firstIndex(where: { $0.id == id }) else {
            throw VaultRepositoryError.entryNotFound(id)
        }

        records.remove(at: index)
        try metadataStore.saveMetadataRecords(records)
        try secureValueStore.deleteValue(for: secureKey(for: id))
    }

    private func entry(for record: VaultEntryMetadataRecord) throws -> VaultEntry {
        guard let encodedPayload = try secureValueStore.loadValue(for: secureKey(for: record.id)) else {
            throw VaultRepositoryError.entryNotFound(record.id)
        }

        let payload = try decoder.decode(VaultEntrySecretPayload.self, from: encodedPayload)
        return VaultEntry(metadata: record.metadata, fields: payload.fields, notes: payload.notes)
    }

    private func secureKey(for id: UUID) -> SecureValueKey {
        SecureValueKey(account: "vault-entry-\(id.uuidString)")
    }
}
