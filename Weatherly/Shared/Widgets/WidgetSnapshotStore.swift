//
//  WidgetSnapshotStore.swift
//  Weatherly
//
//  Created by Pekomon on 10.4.2026.
//

import Foundation

enum WeatherlyWidgetConfiguration {
    static let kind = "WeatherlyWidget"
}

enum WeatherlyWidgetAppGroup {
    static let identifier = "group.com.pekomon.weatherly"
}

struct WidgetSnapshotStore {
    private static let snapshotKey = "widget.weather.snapshot"

    private let userDefaults: UserDefaults?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults? = UserDefaults(suiteName: WeatherlyWidgetAppGroup.identifier)) {
        self.userDefaults = userDefaults
    }

    func saveSnapshot(_ snapshot: WidgetWeatherSnapshot) {
        guard let data = try? encoder.encode(snapshot) else {
            return
        }

        userDefaults?.set(data, forKey: Self.snapshotKey)
    }

    func loadSnapshot() -> WidgetWeatherSnapshot? {
        guard
            let data = userDefaults?.data(forKey: Self.snapshotKey),
            let snapshot = try? decoder.decode(WidgetWeatherSnapshot.self, from: data)
        else {
            return nil
        }

        return snapshot
    }

    func clearSnapshot() {
        userDefaults?.removeObject(forKey: Self.snapshotKey)
    }
}
