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

    func updateQuery(_ query: String) {
        state.query = query

        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            clearResults()
        }
    }

    func clearResults() {
        state.isLoading = false
        state.results = []
        state.errorMessage = nil
    }
}
