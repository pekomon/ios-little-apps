//
//  UserDefaultsAppSettingsRepository.swift
//  Weatherly
//
//  Created by Pekomon on 6.4.2026.
//

import Foundation

final class UserDefaultsAppSettingsRepository: AppSettingsRepository {
    private enum StorageKey {
        static let temperatureUnit = "settings.temperatureUnit"
        static let windSpeedUnit = "settings.windSpeedUnit"
        static let appearancePreference = "settings.appearancePreference"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func fetchSettings() -> AppSettings {
        AppSettings(
            temperatureUnit: storedTemperatureUnit(),
            windSpeedUnit: storedWindSpeedUnit(),
            appearancePreference: storedAppearancePreference()
        )
    }

    func saveSettings(_ settings: AppSettings) {
        userDefaults.set(settings.temperatureUnit.rawValue, forKey: StorageKey.temperatureUnit)
        userDefaults.set(settings.windSpeedUnit.rawValue, forKey: StorageKey.windSpeedUnit)
        userDefaults.set(settings.appearancePreference.rawValue, forKey: StorageKey.appearancePreference)
    }

    private func storedTemperatureUnit() -> TemperatureUnit {
        guard
            let rawValue = userDefaults.string(forKey: StorageKey.temperatureUnit),
            let unit = TemperatureUnit(rawValue: rawValue)
        else {
            return .celsius
        }

        return unit
    }

    private func storedWindSpeedUnit() -> WindSpeedUnit {
        guard
            let rawValue = userDefaults.string(forKey: StorageKey.windSpeedUnit),
            let unit = WindSpeedUnit(rawValue: rawValue)
        else {
            return .metersPerSecond
        }

        return unit
    }

    private func storedAppearancePreference() -> AppAppearancePreference {
        guard
            let rawValue = userDefaults.string(forKey: StorageKey.appearancePreference),
            let preference = AppAppearancePreference(rawValue: rawValue)
        else {
            return .system
        }

        return preference
    }
}
