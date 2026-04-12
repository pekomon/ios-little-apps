//
//  CurrentWeatherCard.swift
//  Weatherly
//
//  Created by Pekomon on 22.3.2026.
//
	

import SwiftUI

struct CurrentWeatherCard: View {
    @Environment(SettingsViewModel.self) private var settingsViewModel

    let weather: WeatherDetails

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text(weather.location.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                if let country = weather.location.country, !country.isEmpty {
                    Text(country)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                } else {
                    Text("Current location")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            
            Image(systemName: weather.current.symbolName)
                .font(.system(size: 64))
                .symbolRenderingMode(.multicolor)
                .accessibilityHidden(true)
            
            VStack(spacing: 6) {
                Text(formatter.temperature(weather.current.temperature))
                    .font(.system(size: 64, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(conditionText(weather.current.condition))
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text("Feels like \(formatter.temperature(weather.current.feelsLike))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .padding(.horizontal, 24)
                .background(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.18),
                            Color.white.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Current weather for \(accessibilityLocationDescription)")
                .accessibilityValue("\(conditionText(weather.current.condition)), \(formatter.temperature(weather.current.temperature)). Feels like \(formatter.temperature(weather.current.feelsLike)).")
    }

    private var formatter: WeatherValueFormatter {
        WeatherValueFormatter(
            temperatureUnit: settingsViewModel.temperatureUnit,
            windSpeedUnit: settingsViewModel.windSpeedUnit
        )
    }
    
    private func conditionText(_ condition: AppWeatherCondition) -> String {
        switch condition {
        case .clear:
            return "Clear"
        case .partlyCloudy:
            return "Partly Cloudy"
        case .cloudy:
            return "Cloudy"
        case .rain:
            return "Rain"
        case .snow:
            return "Snow"
        case .thunderstorm:
            return "Thunderstorm"
        case .fog:
            return "Fog"
        case .wind:
            return "Windy"
        case .unknown:
            return "Unknown"
        }
    }

    private var accessibilityLocationDescription: String {
        if let country = weather.location.country, !country.isEmpty {
            return "\(weather.location.name), \(country)"
        }

        return weather.location.name
    }
}

#Preview {
    CurrentWeatherCard(weather: HomeMockData.weatherDetails)
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
