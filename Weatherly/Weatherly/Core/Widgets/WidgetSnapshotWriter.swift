//
//  WidgetSnapshotWriter.swift
//  Weatherly
//
//  Created by Pekomon on 10.4.2026.
//

import Foundation
import WidgetKit

struct WidgetSnapshotWriter {
    private let snapshotStore: WidgetSnapshotStore

    init(snapshotStore: WidgetSnapshotStore = WidgetSnapshotStore()) {
        self.snapshotStore = snapshotStore
    }

    func writeSnapshot(from weatherDetails: WeatherDetails) {
        let snapshot = WidgetWeatherSnapshot(
            locationName: weatherDetails.location.name,
            temperature: weatherDetails.current.temperature,
            conditionText: weatherDetails.current.condition.widgetDescription,
            symbolName: weatherDetails.current.symbolName,
            updatedAt: weatherDetails.updatedAt,
            dailyForecasts: Array(weatherDetails.dailyForecast.prefix(3)).map { forecast in
                WidgetWeatherSnapshot.DailyForecast(
                    date: forecast.date,
                    minTemperature: forecast.minTemperature,
                    maxTemperature: forecast.maxTemperature,
                    symbolName: forecast.symbolName
                )
            }
        )

        snapshotStore.saveSnapshot(snapshot)
        WidgetCenter.shared.reloadTimelines(ofKind: WeatherlyWidgetConfiguration.kind)
    }
}

private extension AppWeatherCondition {
    var widgetDescription: String {
        switch self {
        case .clear:
            "Clear"
        case .partlyCloudy:
            "Partly Cloudy"
        case .cloudy:
            "Cloudy"
        case .rain:
            "Rain"
        case .snow:
            "Snow"
        case .thunderstorm:
            "Thunderstorm"
        case .fog:
            "Fog"
        case .wind:
            "Windy"
        case .unknown:
            "Weather"
        }
    }
}
