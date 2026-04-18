//
//  VaultEntryField.swift
//  LockBox
//
//  Created by Pekomon on 18.4.2026.
//

import Foundation

struct VaultEntryField: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    let label: String
    let value: String
    let kind: VaultEntryFieldKind

    init(
        id: UUID = UUID(),
        label: String,
        value: String,
        kind: VaultEntryFieldKind
    ) {
        self.id = id
        self.label = label
        self.value = value
        self.kind = kind
    }
}

enum VaultEntryFieldKind: String, Hashable, Codable, CaseIterable, Sendable {
    case username
    case password
    case oneTimeCode
    case url
    case emailAddress
    case phoneNumber
    case text

    var isSensitive: Bool {
        switch self {
        case .password, .oneTimeCode:
            true
        case .username, .url, .emailAddress, .phoneNumber, .text:
            false
        }
    }
}
