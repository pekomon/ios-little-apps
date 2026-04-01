//
//  SearchState.swift
//  Weatherly
//
//  Created by Pekomon on 31.3.2026.
//

import Foundation

struct SearchState {
    var query: String = ""
    var isLoading = false
    var results: [Location] = []
    var errorMessage: String?
}
