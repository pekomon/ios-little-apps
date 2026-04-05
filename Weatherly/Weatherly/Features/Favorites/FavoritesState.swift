//
//  FavoritesState.swift
//  Weatherly
//
//  Created by Pekomon on 4.4.2026.
//

import Foundation

enum FavoritesState {
    case idle
    case loading
    case empty
    case loaded([Location])
}
