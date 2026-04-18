//
//  VaultEntryMetadata.swift
//  LockBox
//
//  Created by Pekomon on 18.4.2026.
//

import Foundation

struct VaultEntryMetadata: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    let kind: VaultEntryKind
    let title: String
    let createdAt: Date
    let updatedAt: Date
    let tags: [String]

    init(
        id: UUID = UUID(),
        kind: VaultEntryKind,
        title: String,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        tags: [String] = []
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tags = tags
    }

    func updatingTimestamp(_ date: Date = .now) -> VaultEntryMetadata {
        VaultEntryMetadata(
            id: id,
            kind: kind,
            title: title,
            createdAt: createdAt,
            updatedAt: date,
            tags: tags
        )
    }
}

enum VaultEntryKind: String, Hashable, Codable, CaseIterable, Sendable {
    case login
    case note
    case card
    case identity
}
