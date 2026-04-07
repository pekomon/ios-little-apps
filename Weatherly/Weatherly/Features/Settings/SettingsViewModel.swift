//
//  SettingsViewModel.swift
//  Weatherly
//
//  Created by Pekomon on 6.4.2026.
//

import Foundation
import Observation
import CoreLocation

@Observable
final class SettingsViewModel {
    private(set) var temperatureUnit: TemperatureUnit
    private(set) var windSpeedUnit: WindSpeedUnit
    private(set) var appearancePreference: AppAppearancePreference
    private(set) var locationAuthorizationStatus: CLAuthorizationStatus

    let appName: String
    let appDescription: String
    let versionDescription: String?

    private let appSettingsRepository: AppSettingsRepository
    private let locationService: LocationService

    init(
        appSettingsRepository: AppSettingsRepository = UserDefaultsAppSettingsRepository(),
        locationService: LocationService = LocationService(),
        bundle: Bundle = .main
    ) {
        self.appSettingsRepository = appSettingsRepository
        self.locationService = locationService

        let settings = appSettingsRepository.fetchSettings()
        temperatureUnit = settings.temperatureUnit
        windSpeedUnit = settings.windSpeedUnit
        appearancePreference = settings.appearancePreference
        locationAuthorizationStatus = locationService.authorizationStatus

        appName = Self.resolveAppName(from: bundle)
        appDescription = "Weatherly keeps current conditions, forecasts, and favorite places close at hand in one calm weather experience."
        versionDescription = Self.resolveVersionDescription(from: bundle)
    }

    func selectTemperatureUnit(_ unit: TemperatureUnit) {
        guard temperatureUnit != unit else {
            return
        }

        temperatureUnit = unit
        persistSettings()
    }

    func selectWindSpeedUnit(_ unit: WindSpeedUnit) {
        guard windSpeedUnit != unit else {
            return
        }

        windSpeedUnit = unit
        persistSettings()
    }

    func selectAppearancePreference(_ preference: AppAppearancePreference) {
        guard appearancePreference != preference else {
            return
        }

        appearancePreference = preference
        persistSettings()
    }

    func refreshLocationAuthorizationStatus() {
        locationService.refreshAuthorizationStatus()
        locationAuthorizationStatus = locationService.authorizationStatus
    }

    var locationAuthorizationStatusText: String {
        switch locationAuthorizationStatus {
        case .notDetermined:
            "Not Determined"
        case .restricted:
            "Restricted"
        case .denied:
            "Denied"
        case .authorizedWhenInUse:
            "Allowed While Using App"
        case .authorizedAlways:
            "Allowed All the Time"
        @unknown default:
            "Unknown"
        }
    }

    var locationAuthorizationDescription: String {
        switch locationAuthorizationStatus {
        case .notDetermined:
            "Weatherly uses your current location to load local weather on the Home tab when you choose to allow access."
        case .restricted:
            "Location access is restricted on this device, so Weatherly cannot use your current position for local weather."
        case .denied:
            "Location access is turned off for Weatherly. Enable it in the system Settings app to use current location weather."
        case .authorizedWhenInUse, .authorizedAlways:
            "Current location is available for local weather updates in Weatherly."
        @unknown default:
            "Location access status could not be determined."
        }
    }

    var canOpenSystemLocationSettings: Bool {
        switch locationAuthorizationStatus {
        case .denied, .restricted:
            true
        case .notDetermined, .authorizedWhenInUse, .authorizedAlways:
            false
        @unknown default:
            false
        }
    }

    private func persistSettings() {
        appSettingsRepository.saveSettings(
            AppSettings(
                temperatureUnit: temperatureUnit,
                windSpeedUnit: windSpeedUnit,
                appearancePreference: appearancePreference
            )
        )
    }

    private static func resolveAppName(from bundle: Bundle) -> String {
        if let displayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String,
           !displayName.isEmpty {
            return displayName
        }

        if let bundleName = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String,
           !bundleName.isEmpty {
            return bundleName
        }

        return "Weatherly"
    }

    private static func resolveVersionDescription(from bundle: Bundle) -> String? {
        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String

        switch (version, build) {
        case let (version?, build?) where !version.isEmpty && !build.isEmpty:
            return "\(version) (\(build))"
        case let (version?, _) where !version.isEmpty:
            return version
        case let (_, build?) where !build.isEmpty:
            return build
        default:
            return nil
        }
    }
}
