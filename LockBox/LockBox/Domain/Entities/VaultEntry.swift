//
//  VaultEntry.swift
//  LockBox
//
//  Created by Pekomon on 18.4.2026.
//

import Foundation

struct VaultEntry: Identifiable, Hashable, Codable, Sendable {
    let metadata: VaultEntryMetadata
    let fields: [VaultEntryField]
    let notes: String

    var id: UUID {
        metadata.id
    }

    init(
        metadata: VaultEntryMetadata,
        fields: [VaultEntryField] = [],
        notes: String = ""
    ) {
        self.metadata = metadata
        self.fields = fields
        self.notes = notes
    }

    func updating(
        metadata: VaultEntryMetadata? = nil,
        fields: [VaultEntryField]? = nil,
        notes: String? = nil
    ) -> VaultEntry {
        VaultEntry(
            metadata: metadata ?? self.metadata,
            fields: fields ?? self.fields,
            notes: notes ?? self.notes
        )
    }
}
