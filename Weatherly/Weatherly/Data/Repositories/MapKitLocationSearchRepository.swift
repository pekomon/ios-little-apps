//
//  MapKitLocationSearchRepository.swift
//  Weatherly
//
//  Created by Pekomon on 31.3.2026.
//

import Foundation
import MapKit

final class MapKitLocationSearchRepository: LocationSearchRepository {
    private var currentRequest: MKGeocodingRequest?

    func searchLocations(matching query: String) async throws -> [Location] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedQuery.isEmpty else {
            return []
        }

        currentRequest?.cancel()

        guard let request = MKGeocodingRequest(addressString: trimmedQuery) else {
            throw LocationSearchError.invalidQuery
        }

        request.preferredLocale = .current
        currentRequest = request

        defer {
            if currentRequest === request {
                currentRequest = nil
            }
        }

        let mapItems = try await request.mapItems
        return deduplicatedLocations(from: mapItems)
    }

    private func deduplicatedLocations(from mapItems: [MKMapItem]) -> [Location] {
        var seen = Set<String>()

        return mapItems.compactMap { mapItem in
            guard let name = locationName(for: mapItem) else {
                return nil
            }

            let coordinate = mapItem.location.coordinate
            let id = locationID(for: coordinate)
            let dedupeKey = "\(name.lowercased())|\(id)"

            guard seen.insert(dedupeKey).inserted else {
                return nil
            }

            return Location(
                id: id,
                name: name,
                country: country(for: mapItem),
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
        }
    }

    private func locationName(for mapItem: MKMapItem) -> String? {
        let candidates = [
            mapItem.addressRepresentations?.cityName,
            mapItem.name,
            mapItem.address?.shortAddress,
            mapItem.address?.fullAddress
        ]

        return candidates.first { candidate in
            guard let candidate else {
                return false
            }

            return !candidate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        } ?? nil
    }

    private func country(for mapItem: MKMapItem) -> String? {
        guard let country = mapItem.addressRepresentations?.regionName else {
            return nil
        }

        let trimmedCountry = country.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedCountry.isEmpty ? nil : trimmedCountry
    }

    private func locationID(for coordinate: CLLocationCoordinate2D) -> String {
        "\(coordinate.latitude),\(coordinate.longitude)"
    }
}

private enum LocationSearchError: LocalizedError {
    case invalidQuery

    var errorDescription: String? {
        switch self {
        case .invalidQuery:
            return "The location search query is invalid."
        }
    }
}
