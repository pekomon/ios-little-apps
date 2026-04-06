//
//  AppSettingsRepository.swift
//  Weatherly
//
//  Created by Pekomon on 6.4.2026.
//

import Foundation

protocol AppSettingsRepository {
    func fetchSettings() -> AppSettings
    func saveSettings(_ settings: AppSettings)
}
