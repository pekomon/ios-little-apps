//
//  CurrentWeatherCard.swift
//  Weatherly
//
//  Created by Pekomon on 22.3.2026.
//
	

import SwiftUI

struct CurrentWeatherCard: View {
    
    let weather: WeatherDetails
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text(weather.location.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if let country = weather.location.country, !country.isEmpty {
                    Text(country)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Current location")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            
            Image(systemName: weather.current.symbolName)
                .font(.system(size: 64))
                .symbolRenderingMode(.multicolor)
            
            VStack(spacing: 6) {
                Text("\(Int(weather.current.temperature.rounded()))°")
                    .font(.system(size: 64, weight: .bold))

                Text(conditionText(weather.current.condition))
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text("Feels like \(Int(weather.current.feelsLike.rounded()))°")
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
}

#Preview {
    CurrentWeatherCard(weather: HomeMockData.weatherDetails)
        .padding()
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.5), .indigo.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
}
