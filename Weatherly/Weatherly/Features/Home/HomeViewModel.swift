//
//  HomeViewModel.swift
//  Weatherly
//
//  Created by Pekomon on 16.3.2026.
//

import Foundation
import Observation
import CoreLocation

@Observable
final class HomeViewModel {
    var state: HomeState = .idle

    private let weatherRepository: WeatherRepository
    private let locationService: LocationService
    private let widgetSnapshotWriter: WidgetSnapshotWriter

    init(
        weatherRepository: WeatherRepository = WeatherKitWeatherRepository(),
        locationService: LocationService = LocationService(),
        widgetSnapshotWriter: WidgetSnapshotWriter = WidgetSnapshotWriter()
    ) {
        self.weatherRepository = weatherRepository
        self.locationService = locationService
        self.widgetSnapshotWriter = widgetSnapshotWriter
    }

    func loadWeather() async {
        state = .loading

        do {
            let currentLocation = try await locationService.requestCurrentLocation()

            let location = Location(
                id: "current-location",
                name: "Current location",
                country: nil,
                latitude: currentLocation.coordinate.latitude,
                longitude: currentLocation.coordinate.longitude
            )

            let weather = try await weatherRepository.fetchWeather(for: location)
            widgetSnapshotWriter.writeSnapshot(from: weather)
            state = .loaded(weather)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
