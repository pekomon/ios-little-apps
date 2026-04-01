//
//  LocationSearchRepository.swift
//  Weatherly
//
//  Created by Pekomon on 31.3.2026.
//

import Foundation

protocol LocationSearchRepository {
    func searchLocations(matching query: String) async throws -> [Location]
}
