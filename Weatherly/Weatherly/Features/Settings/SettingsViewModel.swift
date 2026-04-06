//
//  SettingsViewModel.swift
//  Weatherly
//
//  Created by Pekomon on 6.4.2026.
//

import Foundation
import Observation

@Observable
final class SettingsViewModel {
    private(set) var temperatureUnit: TemperatureUnit
    private(set) var windSpeedUnit: WindSpeedUnit
    private(set) var appearancePreference: AppAppearancePreference

    let appName: String
    let appDescription: String
    let versionDescription: String?

    private let appSettingsRepository: AppSettingsRepository

    init(
        appSettingsRepository: AppSettingsRepository = UserDefaultsAppSettingsRepository(),
        bundle: Bundle = .main
    ) {
        self.appSettingsRepository = appSettingsRepository

        let settings = appSettingsRepository.fetchSettings()
        temperatureUnit = settings.temperatureUnit
        windSpeedUnit = settings.windSpeedUnit
        appearancePreference = settings.appearancePreference

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
