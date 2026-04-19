//
//  VaultEntryMetadataStore.swift
//  LockBox
//
//  Created by Pekomon on 19.4.2026.
//

import Foundation

protocol VaultEntryMetadataStoring {
    func loadMetadataRecords() throws -> [VaultEntryMetadataRecord]
    func saveMetadataRecords(_ records: [VaultEntryMetadataRecord]) throws
}
