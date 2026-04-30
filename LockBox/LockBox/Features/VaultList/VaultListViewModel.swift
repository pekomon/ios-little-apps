//
//  VaultListViewModel.swift
//  LockBox
//
//  Created by Pekomon on 20.4.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class VaultListViewModel {
    private let repository: any VaultRepository
    private let hapticFeedbackService: any HapticFeedbackServicing
    private(set) var entries: [VaultEntry] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private var hasLoaded = false

    init(
        repository: any VaultRepository,
        hapticFeedbackService: any HapticFeedbackServicing = HapticFeedbackService()
    ) {
        self.repository = repository
        self.hapticFeedbackService = hapticFeedbackService
    }

    func makeEntryEditorViewModel() -> EntryEditorViewModel {
        EntryEditorViewModel(
            repository: repository,
            hapticFeedbackService: hapticFeedbackService
        )
    }

    func makeEntryEditorViewModel(for entry: VaultEntry) -> EntryEditorViewModel {
        EntryEditorViewModel(
            repository: repository,
            hapticFeedbackService: hapticFeedbackService,
            entry: entry
        )
    }

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        await reload()
    }

    func reload() async {
        isLoading = true
        errorMessage = nil

        do {
            var loadedEntries = try await repository.fetchEntries()

            if loadedEntries.isEmpty && !hasLoaded {
                try await seedSampleEntries()
                loadedEntries = try await repository.fetchEntries()
            }

            entries = loadedEntries
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshEntry(id: VaultEntry.ID) async throws -> VaultEntry {
        let entry = try await repository.fetchEntry(id: id)
        await reload()
        return entry
    }

    func deleteEntry(id: VaultEntry.ID) async throws {
        try await repository.deleteEntry(id: id)
        await reload()
    }

    private func seedSampleEntries() async throws {
        let now = Date()
        let samples = [
            VaultEntry(
                metadata: VaultEntryMetadata(
                    kind: .login,
                    title: "Fastmail",
                    createdAt: now.addingTimeInterval(-86_400 * 7),
                    updatedAt: now.addingTimeInterval(-3_600),
                    tags: ["email", "personal"]
                ),
                fields: [
                    VaultEntryField(label: "Email", value: "pekka@example.com", kind: .emailAddress),
                    VaultEntryField(label: "Password", value: "correct-horse-battery-staple", kind: .password),
                    VaultEntryField(label: "Website", value: "https://app.fastmail.com", kind: .url)
                ],
                notes: "Primary email account used for personal communication."
            ),
            VaultEntry(
                metadata: VaultEntryMetadata(
                    kind: .card,
                    title: "Travel Card",
                    createdAt: now.addingTimeInterval(-86_400 * 21),
                    updatedAt: now.addingTimeInterval(-86_400 * 2),
                    tags: ["finance", "travel"]
                ),
                fields: [
                    VaultEntryField(label: "Card Number", value: "4242 4242 4242 4242", kind: .text),
                    VaultEntryField(label: "Customer Service", value: "+358 10 123 4567", kind: .phoneNumber)
                ],
                notes: "Low-limit card kept for trips and one-off online purchases."
            ),
            VaultEntry(
                metadata: VaultEntryMetadata(
                    kind: .note,
                    title: "Household Wi-Fi",
                    createdAt: now.addingTimeInterval(-86_400 * 3),
                    updatedAt: now,
                    tags: ["home", "shared"]
                ),
                fields: [
                    VaultEntryField(label: "Network", value: "Birch-House", kind: .text),
                    VaultEntryField(label: "Password", value: "northern-lights-2026", kind: .password)
                ],
                notes: "Guest network credentials for visitors."
            )
        ]

        for entry in samples {
            try await repository.saveEntry(entry)
        }
    }
}
