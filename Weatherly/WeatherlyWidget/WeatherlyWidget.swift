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
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    var temperatureText: String {
        "\(Int(temperature.rounded()))°"
    }

    var highLowText: String? {
        guard let today = dailyForecasts.first else {
            return nil
        }

        return "H:\(Int(today.maxTemperature.rounded()))°  L:\(Int(today.minTemperature.rounded()))°"
    }

    var updatedText: String {
        let relative = Self.relativeFormatter.localizedString(for: updatedAt, relativeTo: .now)
        return "Updated \(relative)"
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
    @Environment(\.widgetFamily) private var widgetFamily
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

            Group {
                switch widgetFamily {
                case .systemMedium:
                    mediumContent
                default:
                    smallContent
                }
            }
            .padding()
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }

    private var smallContent: some View {
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

            Text(entry.snapshot.updatedText)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.75))
        }
        .foregroundStyle(.white)
    }

    private var mediumContent: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.snapshot.locationName)
                    .font(.headline)
                    .fontWeight(.semibold)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(entry.snapshot.temperatureText)
                        .font(.system(size: 40, weight: .bold, design: .rounded))

                    Image(systemName: entry.snapshot.symbolName)
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                }

                Text(entry.snapshot.conditionText)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))

                if let highLowText = entry.snapshot.highLowText {
                    Text(highLowText)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                }

                Spacer(minLength: 0)

                Text(entry.snapshot.updatedText)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.75))
            }
            .foregroundStyle(.white)

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(entry.snapshot.dailyForecasts.prefix(3))) { forecast in
                    HStack(spacing: 8) {
                        Text(forecast.dayLabel)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(width: 26, alignment: .leading)

                        Image(systemName: forecast.symbolName)
                            .font(.caption)
                            .frame(width: 14, alignment: .center)

                        Text(forecast.temperatureRangeText)
                            .font(.caption)
                    }
                    .foregroundStyle(.white.opacity(0.92))
                }
            }
        }
    }
}

private extension WidgetWeatherSnapshot.DailyForecast {
    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEE")
        return formatter
    }()

    var dayLabel: String {
        Self.weekdayFormatter.string(from: date)
    }

    var temperatureRangeText: String {
        "\(Int(maxTemperature.rounded()))° / \(Int(minTemperature.rounded()))°"
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
        .supportedFamilies([.systemSmall, .systemMedium])
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

#Preview(as: .systemMedium) {
    WeatherlyWidget()
} timeline: {
    WeatherlyWidgetEntry.placeholder
}
