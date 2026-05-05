//
//  HourlyForecastSection.swift
//  Weatherly
//
//  Created by Pekomon on 22.3.2026.
//
	

import SwiftUI

struct HourlyForecastSection: View {
    @Environment(SettingsViewModel.self) private var settingsViewModel

    let items: [HourlyForecast]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Hourly Forecast", systemImage: "clock")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(displayItems) { item in
                        HourlyForecastItemView(
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

    private var displayItems: [HourlyForecast] {
        let sortedItems = items.sorted { $0.date < $1.date }
        let calendar = Calendar.autoupdatingCurrent
        let currentHourStart = calendar.dateInterval(of: .hour, for: Date())?.start ?? Date()
        let upcomingItems = sortedItems.filter { $0.date >= currentHourStart }

        return Array((upcomingItems.isEmpty ? sortedItems : upcomingItems).prefix(12))
    }
}

private struct HourlyForecastItemView: View {
    let item: HourlyForecast
    let formatter: WeatherValueFormatter

    var body: some View {
        VStack(spacing: 12) {
            Text(item.date, format: .dateTime.hour())
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.9)

            Image(systemName: item.symbolName)
                .font(.title3)
                .symbolRenderingMode(.multicolor)
                .accessibilityHidden(true)

            Text(formatter.temperature(item.temperature))
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(width: 76)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.10))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Forecast at \(item.date.formatted(date: .omitted, time: .shortened))")
        .accessibilityValue(formatter.temperature(item.temperature))
    }
}

#Preview {
    HourlyForecastSection(items: HomeMockData.weatherDetails.hourlyForecast)
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
