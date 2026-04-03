//
//  SearchViewModel.swift
//  Weatherly
//
//  Created by Pekomon on 31.3.2026.
//

import Foundation
import Observation

@Observable
final class SearchViewModel {
    var state = SearchState()

    private let locationSearchRepository: LocationSearchRepository
    private let recentSearchStore: SearchRecentSearchStore
    private var searchTask: Task<Void, Never>?

    init(
        locationSearchRepository: LocationSearchRepository = MapKitLocationSearchRepository(),
        recentSearchStore: SearchRecentSearchStore = UserDefaultsSearchRecentSearchStore()
    ) {
        self.locationSearchRepository = locationSearchRepository
        self.recentSearchStore = recentSearchStore
        state.recentSearches = recentSearchStore.loadRecentSearches()
    }

    func updateQuery(_ query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        state.query = query
        state.errorMessage = nil

        searchTask?.cancel()

        if trimmedQuery.isEmpty {
            clearResults()
            return
        }

        guard trimmedQuery.count >= 2 else {
            state.isLoading = false
            state.results = []
            return
        }

        state.isLoading = true

        let currentQuery = query
        searchTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .milliseconds(300))
                try Task.checkCancellation()

                guard let self else { return }

                let locations = try await self.locationSearchRepository.searchLocations(matching: currentQuery)
                try Task.checkCancellation()

                guard self.state.query == currentQuery else { return }

                self.state.results = locations
                self.state.errorMessage = nil
                self.state.isLoading = false
            } catch is CancellationError {
                guard let self else { return }
                guard self.state.query == currentQuery else { return }
                self.state.isLoading = false
            } catch {
                guard let self else { return }
                guard self.state.query == currentQuery else { return }

                self.state.results = []
                self.state.errorMessage = "Unable to search locations right now. Please try again."
                self.state.isLoading = false
            }
        }
    }

    func clearResults() {
        searchTask?.cancel()
        state.isLoading = false
        state.results = []
        state.errorMessage = nil
    }

    func saveRecentSearch(_ location: Location) {
        recentSearchStore.saveRecentSearch(location)
        state.recentSearches = recentSearchStore.loadRecentSearches()
    }

    func clearRecentSearches() {
        recentSearchStore.clearRecentSearches()
        state.recentSearches = []
    }
}
