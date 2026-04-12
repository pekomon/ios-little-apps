//
//  MapKitLocationSearchRepository.swift
//  Weatherly
//
//  Created by Pekomon on 31.3.2026.
//

import Foundation
import MapKit

final class MapKitLocationSearchRepository: NSObject, LocationSearchRepository {
    @MainActor private var completer: MKLocalSearchCompleter?
    @MainActor private var continuation: CheckedContinuation<[MKLocalSearchCompletion], Error>?

    func searchLocations(matching query: String) async throws -> [Location] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedQuery.isEmpty else {
            return []
        }

        let completions = try await fetchCompletions(for: trimmedQuery)
        let mapItems = try await resolveMapItems(from: completions)
        return deduplicatedLocations(from: mapItems)
    }

    @MainActor
    private func fetchCompletions(for query: String) async throws -> [MKLocalSearchCompletion] {
        let completer = configuredCompleter()

        if let continuation {
            continuation.resume(throwing: CancellationError())
            self.continuation = nil
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            completer.queryFragment = query
        }
    }

    @MainActor
    private func configuredCompleter() -> MKLocalSearchCompleter {
        if let completer {
            return completer
        }

        let completer = MKLocalSearchCompleter()
        completer.delegate = self
        completer.resultTypes = [.address]
        completer.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 140, longitudeDelta: 320)
        )
        self.completer = completer
        return completer
    }

    private func resolveMapItems(from completions: [MKLocalSearchCompletion]) async throws -> [MKMapItem] {
        var resolvedItems: [MKMapItem] = []

        for completion in completions.prefix(8) {
            try Task.checkCancellation()

            let request = MKLocalSearch.Request(completion: completion)
            request.resultTypes = [.address]
            let search = MKLocalSearch(request: request)
            let response = try await search.start()

            if let mapItem = response.mapItems.first {
                resolvedItems.append(mapItem)
            }
        }

        return resolvedItems
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

extension MapKitLocationSearchRepository: MKLocalSearchCompleterDelegate {
    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            let results = Array(completer.results.prefix(8))
            continuation?.resume(returning: results)
            continuation = nil
        }
    }

    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        Task { @MainActor in
            continuation?.resume(throwing: error)
            continuation = nil
        }
    }
}
