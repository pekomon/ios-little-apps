//
//  DailyForecastSection.swift
//  Weatherly
//
//  Created by Pekomon on 22.3.2026.
//
	

import SwiftUI

struct DailyForecastSection: View {
    @Environment(SettingsViewModel.self) private var settingsViewModel

    let items: [DailyForecast]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Daily Forecast", systemImage: "calendar")

            VStack(spacing: 8) {
                ForEach(Array(items.prefix(7))) { item in
                    DailyForecastRow(
                        item: item,
                        formatter: WeatherValueFormatter(
                            temperatureUnit: settingsViewModel.temperatureUnit,
                            windSpeedUnit: settingsViewModel.windSpeedUnit
                        )
                    )
                }
            }
        }
    }
}

private struct DailyForecastRow: View {
    let item: DailyForecast
    let formatter: WeatherValueFormatter

    var body: some View {
        HStack(spacing: 12) {
            Text(item.date, format: .dateTime.weekday(.abbreviated))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(minWidth: 56, alignment: .leading)

            Image(systemName: item.symbolName)
                .frame(width: 24)
                .symbolRenderingMode(.multicolor)
                .accessibilityHidden(true)

            Spacer()

            Text(formatter.temperature(item.minTemperature))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Text(formatter.temperature(item.maxTemperature))
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .padding(16)
        .background(Color.white.opacity(0.10))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.date.formatted(.dateTime.weekday(.wide)))
        .accessibilityValue("Low \(formatter.temperature(item.minTemperature)), high \(formatter.temperature(item.maxTemperature))")
    }
}

#Preview {
    DailyForecastSection(items: HomeMockData.weatherDetails.dailyForecast)
        .environment(SettingsViewModel())
        .padding()
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.5), .indigo.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
}
