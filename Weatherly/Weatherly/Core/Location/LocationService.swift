//
//  LocationService.swift
//  Weatherly
//
//  Created by Pekomon on 21.3.2026.
//

import CoreLocation
import Foundation
import Observation

@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager: CLLocationManager
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    var authorizationStatus: CLAuthorizationStatus

    override init() {
        let manager = CLLocationManager()
        self.manager = manager
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        self.manager.delegate = self
    }

    func requestWhenInUseAuthorization() async -> CLAuthorizationStatus {
        let status = manager.authorizationStatus

        guard status == .notDetermined else {
            return status
        }

        return await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            manager.requestWhenInUseAuthorization()
        }
    }

    func requestCurrentLocation() async throws -> CLLocation {
        let authorizationStatus = await requestWhenInUseAuthorization()

        switch authorizationStatus {
        case .notDetermined:
            throw LocationError.authorizationNotDetermined
        case .denied:
            throw LocationError.permissionDenied
        case .restricted:
            throw LocationError.permissionRestricted
        case .authorizedWhenInUse, .authorizedAlways:
            break
        @unknown default:
            throw LocationError.unknownAuthorizationStatus
        }

        if let location = manager.location {
            return location
        }

        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        guard manager.authorizationStatus != .notDetermined else {
            return
        }

        authorizationContinuation?.resume(returning: manager.authorizationStatus)
        authorizationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            locationContinuation?.resume(throwing: LocationError.locationUnavailable)
            locationContinuation = nil
            return
        }

        locationContinuation?.resume(returning: location)
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
}

enum LocationError: LocalizedError {
    case authorizationNotDetermined
    case permissionDenied
    case permissionRestricted
    case locationUnavailable
    case unknownAuthorizationStatus

    var errorDescription: String? {
        switch self {
        case .authorizationNotDetermined:
            return "Location permission has not been determined yet."
        case .permissionDenied:
            return "Location permission was denied."
        case .permissionRestricted:
            return "Location access is restricted."
        case .locationUnavailable:
            return "Current location is unavailable."
        case .unknownAuthorizationStatus:
            return "Unknown location authorization status."
        }
    }
}
