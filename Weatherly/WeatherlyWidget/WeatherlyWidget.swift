//
//  WeatherlyWidget.swift
//  WeatherlyWidget
//
//  Created by Pekomon on 10.4.2026.
//

import SwiftUI
import WidgetKit

private let snapshotStore = WidgetSnapshotStore()

struct WeatherlyWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetWeatherSnapshot
}

private extension WeatherlyWidgetEntry {
    init(snapshot: WidgetWeatherSnapshot) {
        self.init(date: snapshot.updatedAt, snapshot: snapshot)
    }

    static let placeholder = WeatherlyWidgetEntry(
        date: WidgetWeatherSnapshot.placeholder.updatedAt,
        snapshot: .placeholder
    )
}

private extension WidgetWeatherSnapshot {
    var temperatureText: String {
        "\(Int(temperature.rounded()))°"
    }

    var highLowText: String? {
        guard let today = dailyForecasts.first else {
            return nil
        }

        return "H:\(Int(today.maxTemperature.rounded()))°  L:\(Int(today.minTemperature.rounded()))°"
    }
}

struct WeatherlyWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherlyWidgetEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherlyWidgetEntry) -> Void) {
        let entry = WeatherlyWidgetEntry(snapshot: snapshotStore.loadSnapshot() ?? .placeholder)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherlyWidgetEntry>) -> Void) {
        let snapshot = snapshotStore.loadSnapshot() ?? .placeholder
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        let timeline = Timeline(entries: [WeatherlyWidgetEntry(snapshot: snapshot)], policy: .after(refreshDate))
        completion(timeline)
    }
}

struct WeatherlyWidgetEntryView: View {
    let entry: WeatherlyWidgetProvider.Entry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.29, blue: 0.53),
                    Color(red: 0.40, green: 0.65, blue: 0.93),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.snapshot.locationName)
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text(entry.snapshot.conditionText)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }

                    Spacer(minLength: 8)

                    Image(systemName: entry.snapshot.symbolName)
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                }

                Spacer()

                Text(entry.snapshot.temperatureText)
                    .font(.system(size: 34, weight: .bold, design: .rounded))

                if let highLowText = entry.snapshot.highLowText {
                    Text(highLowText)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .foregroundStyle(.white)
            .padding()
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

struct WeatherlyWidget: Widget {
    let kind = WeatherlyWidgetConfiguration.kind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherlyWidgetProvider()) { entry in
            WeatherlyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Current Weather")
        .description("A compact weather snapshot from Weatherly.")
        .supportedFamilies([.systemSmall])
    }
}

@main
struct WeatherlyWidgetBundle: WidgetBundle {
    var body: some Widget {
        WeatherlyWidget()
    }
}

#Preview(as: .systemSmall) {
    WeatherlyWidget()
} timeline: {
    WeatherlyWidgetEntry.placeholder
}
