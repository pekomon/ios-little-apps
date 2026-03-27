//
//  WeatherMetricGrid.swift
//  Weatherly
//
//  Created by Pekomon on 22.3.2026.
//
	

import SwiftUI

struct WeatherMetricGrid: View {
    let weather: WeatherDetails

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Today's Details", systemImage: "square.grid.2x2")

            LazyVGrid(columns: columns, spacing: 12) {
                MetricCard(
                    title: "Feels Like",
                    value: "\(Int(weather.current.feelsLike.rounded()))°",
                    systemImage: "thermometer"
                )

                MetricCard(
                    title: "Humidity",
                    value: "\(Int(weather.current.humidity.rounded()))%",
                    systemImage: "humidity"
                )

                MetricCard(
                    title: "Wind",
                    value: "\(weather.current.windSpeed.formatted(.number.precision(.fractionLength(1)))) m/s",
                    systemImage: "wind"
                )

                MetricCard(
                    title: "Pressure",
                    value: "\(Int(weather.current.pressure.rounded())) hPa",
                    systemImage: "gauge"
                )
            }
        }
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .padding(16)
        .background(Color.white.opacity(0.10))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    WeatherMetricGrid(weather: HomeMockData.weatherDetails)
        .padding()
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.5), .indigo.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
}
