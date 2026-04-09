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
                    ForEach(Array(items.prefix(12))) { item in
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
}

private struct HourlyForecastItemView: View {
    let item: HourlyForecast
    let formatter: WeatherValueFormatter

    var body: some View {
        VStack(spacing: 12) {
            Text(item.date, format: .dateTime.hour())
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Image(systemName: item.symbolName)
                .font(.title3)
                .symbolRenderingMode(.multicolor)

            Text(formatter.temperature(item.temperature))
                .fontWeight(.semibold)
        }
        .frame(width: 76)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.10))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
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
