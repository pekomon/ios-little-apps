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
            Text(weather.location.name)
                .font(.title2)
                .fontWeight(.semibold)
            
            Image(systemName: weather.current.symbolName)
                .font(.system(size: 56))
                .symbolRenderingMode(.multicolor)
            
            Text("\(Int(weather.current.temperature.rounded()))°")
                .font(.system(size: 56, weight: .bold))
            
            Text(conditionText(weather.current.condition))
                .font(.headline)
                .foregroundStyle(.secondary)
                
        }
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

#Preview("CurrentWeatherCard", traits: .sizeThatFitsLayout) {
    CurrentWeatherCard(weather: HomeMockData.weatherDetails)
        .padding()
        .background(Color(.systemBackground))
}

