//
//  VaultRepository.swift
//  LockBox
//
//  Created by Pekomon on 19.4.2026.
//

import Foundation

protocol VaultRepository: Sendable {
    func fetchEntries() async throws -> [VaultEntry]
    func fetchEntry(id: VaultEntry.ID) async throws -> VaultEntry
    func saveEntry(_ entry: VaultEntry) async throws
    func deleteEntry(id: VaultEntry.ID) async throws
}

enum VaultRepositoryError: LocalizedError, Equatable, Sendable {
    case entryNotFound(VaultEntry.ID)

    var errorDescription: String? {
        switch self {
        case .entryNotFound:
            "The requested vault entry could not be found."
        }
    }
}
