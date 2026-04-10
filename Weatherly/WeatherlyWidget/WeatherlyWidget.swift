//
//  WeatherlyWidget.swift
//  WeatherlyWidget
//
//  Created by Pekomon on 10.4.2026.
//

import SwiftUI
import WidgetKit

private enum WeatherlyWidgetSampleEntry {
    static let placeholder = WeatherlyWidgetEntry(
        date: .now,
        cityName: "Helsinki",
        conditionSymbolName: "cloud.sun.fill",
        temperatureText: "12°",
        summaryText: "Partly Cloudy",
        highLowText: "H:15°  L:8°"
    )
}

struct WeatherlyWidgetEntry: TimelineEntry {
    let date: Date
    let cityName: String
    let conditionSymbolName: String
    let temperatureText: String
    let summaryText: String
    let highLowText: String
}

struct WeatherlyWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherlyWidgetEntry {
        WeatherlyWidgetSampleEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherlyWidgetEntry) -> Void) {
        completion(WeatherlyWidgetSampleEntry.placeholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherlyWidgetEntry>) -> Void) {
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        let timeline = Timeline(entries: [WeatherlyWidgetSampleEntry.placeholder], policy: .after(refreshDate))
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
                        Text(entry.cityName)
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text(entry.summaryText)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }

                    Spacer(minLength: 8)

                    Image(systemName: entry.conditionSymbolName)
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                }

                Spacer()

                Text(entry.temperatureText)
                    .font(.system(size: 34, weight: .bold, design: .rounded))

                Text(entry.highLowText)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
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
    let kind = "WeatherlyWidget"

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
    WeatherlyWidgetSampleEntry.placeholder
}
