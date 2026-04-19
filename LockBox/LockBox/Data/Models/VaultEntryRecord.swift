//
//  VaultEntryRecord.swift
//  LockBox
//
//  Created by Pekomon on 19.4.2026.
//

import Foundation

struct VaultEntryMetadataRecord: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let kind: VaultEntryKind
    let title: String
    let createdAt: Date
    let updatedAt: Date
    let tags: [String]

    init(metadata: VaultEntryMetadata) {
        self.id = metadata.id
        self.kind = metadata.kind
        self.title = metadata.title
        self.createdAt = metadata.createdAt
        self.updatedAt = metadata.updatedAt
        self.tags = metadata.tags
    }

    var metadata: VaultEntryMetadata {
        VaultEntryMetadata(
            id: id,
            kind: kind,
            title: title,
            createdAt: createdAt,
            updatedAt: updatedAt,
            tags: tags
        )
    }
}

struct VaultEntrySecretPayload: Codable, Hashable, Sendable {
    let fields: [VaultEntryField]
    let notes: String
}
