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
        Group {
            switch widgetFamily {
            case .systemMedium:
                mediumContent
            default:
                smallContent
            }
        }
        .padding(14)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [
                    Color(red: 0.14, green: 0.24, blue: 0.44),
                    Color(red: 0.31, green: 0.54, blue: 0.83),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var smallContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.snapshot.locationName)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .lineLimit(1)

                    Text(entry.snapshot.conditionText)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.82))
                        .lineLimit(1)
                }

                Spacer(minLength: 10)

                Image(systemName: entry.snapshot.symbolName)
                    .font(.system(size: 21, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
            }

            Spacer(minLength: 0)

            Text(entry.snapshot.temperatureText)
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .monospacedDigit()

            if let highLowText = entry.snapshot.highLowText {
                Text(highLowText)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.86))
            }

            Text(entry.snapshot.updatedText)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
        }
        .foregroundStyle(.white)
    }

    private var mediumContent: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Text(entry.snapshot.locationName)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.semibold)
                    .lineLimit(1)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(entry.snapshot.temperatureText)
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .monospacedDigit()

                    Image(systemName: entry.snapshot.symbolName)
                        .font(.system(size: 22, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                }

                Text(entry.snapshot.conditionText)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.82))
                    .lineLimit(1)

                if let highLowText = entry.snapshot.highLowText {
                    Text(highLowText)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.86))
                }

                Spacer(minLength: 0)

                Text(entry.snapshot.updatedText)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
            }
            .foregroundStyle(.white)

            Spacer(minLength: 8)

            VStack(alignment: .leading, spacing: 8) {
                Text("3-Day Outlook")
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.72))

                ForEach(Array(entry.snapshot.dailyForecasts.prefix(3))) { forecast in
                    HStack(spacing: 10) {
                        Text(forecast.dayLabel)
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.semibold)
                            .frame(width: 30, alignment: .leading)

                        Image(systemName: forecast.symbolName)
                            .font(.system(size: 12, weight: .semibold))
                            .frame(width: 16, alignment: .center)

                        Text(forecast.temperatureRangeText)
                            .font(.system(.caption, design: .rounded))
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .foregroundStyle(.white.opacity(0.94))
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

private extension WidgetWeatherSnapshot {
    static let previewRainy = WidgetWeatherSnapshot(
        locationName: "Helsinki",
        temperature: 9,
        conditionText: "Rain Showers",
        symbolName: "cloud.rain.fill",
        updatedAt: .now.addingTimeInterval(-8 * 60),
        dailyForecasts: [
            .init(date: .now, minTemperature: 6, maxTemperature: 10, symbolName: "cloud.rain.fill"),
            .init(
                date: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now,
                minTemperature: 5,
                maxTemperature: 11,
                symbolName: "cloud.sun.rain.fill"
            ),
            .init(
                date: Calendar.current.date(byAdding: .day, value: 2, to: .now) ?? .now,
                minTemperature: 4,
                maxTemperature: 9,
                symbolName: "cloud.bolt.rain.fill"
            ),
        ]
    )
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
    WeatherlyWidgetEntry(snapshot: .placeholder)
    WeatherlyWidgetEntry(snapshot: .previewRainy)
}

#Preview(as: .systemMedium) {
    WeatherlyWidget()
} timeline: {
    WeatherlyWidgetEntry(snapshot: .placeholder)
    WeatherlyWidgetEntry(snapshot: .previewRainy)
}
