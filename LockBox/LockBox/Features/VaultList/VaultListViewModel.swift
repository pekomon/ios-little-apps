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

    convenience init(repository: any VaultRepository) {
        self.init(
            repository: repository,
            hapticFeedbackService: HapticFeedbackService()
        )
    }

    init(
        repository: any VaultRepository,
        hapticFeedbackService: any HapticFeedbackServicing
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
            entries = try await repository.fetchEntries()
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
}
