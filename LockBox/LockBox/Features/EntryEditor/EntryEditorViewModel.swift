//
//  EntryEditorViewModel.swift
//  LockBox
//
//  Created by Pekomon on 21.4.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class EntryEditorViewModel: Identifiable {
    private let repository: any VaultRepository
    let id = UUID()

    var title = ""
    var kind: VaultEntryKind = .login
    var notes = ""
    var tagsText = ""
    var primaryValue = ""
    var secondaryValue = ""
    var tertiaryValue = ""
    var isSaving = false
    var errorMessage: String?

    init(repository: any VaultRepository) {
        self.repository = repository
    }

    var primaryLabel: String {
        fieldLabels.primary
    }

    var secondaryLabel: String {
        fieldLabels.secondary
    }

    var tertiaryLabel: String {
        fieldLabels.tertiary
    }

    var primaryKeyboard: EntryEditorKeyboard {
        fieldKinds.primary.keyboard
    }

    var secondaryKeyboard: EntryEditorKeyboard {
        fieldKinds.secondary.keyboard
    }

    var tertiaryKeyboard: EntryEditorKeyboard {
        fieldKinds.tertiary.keyboard
    }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSaving
    }

    func save() async -> Bool {
        guard canSave else { return false }

        isSaving = true
        errorMessage = nil

        let entry = VaultEntry(
            metadata: VaultEntryMetadata(
                kind: kind,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                tags: parsedTags
            ),
            fields: builtFields,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        do {
            try await repository.saveEntry(entry)
            isSaving = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isSaving = false
            return false
        }
    }

    private var parsedTags: [String] {
        tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private var builtFields: [VaultEntryField] {
        [
            buildField(label: fieldLabels.primary, value: primaryValue, kind: fieldKinds.primary),
            buildField(label: fieldLabels.secondary, value: secondaryValue, kind: fieldKinds.secondary),
            buildField(label: fieldLabels.tertiary, value: tertiaryValue, kind: fieldKinds.tertiary)
        ]
        .compactMap { $0 }
    }

    private var fieldLabels: (primary: String, secondary: String, tertiary: String) {
        switch kind {
        case .login:
            return ("Email or Username", "Password", "Website")
        case .note:
            return ("Reference", "Related Link", "Extra Detail")
        case .card:
            return ("Card Number", "Support Phone", "Website")
        case .identity:
            return ("Full Name", "Email", "Phone")
        }
    }

    private var fieldKinds: (primary: VaultEntryFieldKind, secondary: VaultEntryFieldKind, tertiary: VaultEntryFieldKind) {
        switch kind {
        case .login:
            return (.emailAddress, .password, .url)
        case .note:
            return (.text, .url, .text)
        case .card:
            return (.text, .phoneNumber, .url)
        case .identity:
            return (.text, .emailAddress, .phoneNumber)
        }
    }

    private func buildField(label: String, value: String, kind: VaultEntryFieldKind) -> VaultEntryField? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return VaultEntryField(label: label, value: trimmed, kind: kind)
    }
}

enum EntryEditorKeyboard {
    case `default`
    case email
    case url
    case phone
}

private extension VaultEntryFieldKind {
    var keyboard: EntryEditorKeyboard {
        switch self {
        case .emailAddress:
            return .email
        case .url:
            return .url
        case .phoneNumber:
            return .phone
        case .username, .password, .oneTimeCode, .text:
            return .default
        }
    }
}
