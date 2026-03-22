//
//  DailyForecastSection.swift
//  Weatherly
//
//  Created by Pekomon on 22.3.2026.
//
	

import SwiftUI

struct DailyForecastSection: View {
    let items: [DailyForecast]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Forecast")
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(Array(items.prefix(7))) { item in
                    DailyForecastRow(item: item)
                }
            }
        }
    }
}

private struct DailyForecastRow: View {
    let item: DailyForecast

    var body: some View {
        HStack(spacing: 12) {
            Text(item.date, format: .dateTime.weekday(.abbreviated))
                .frame(width: 48, alignment: .leading)

            Image(systemName: item.symbolName)
                .frame(width: 24)
                .symbolRenderingMode(.multicolor)

            Spacer()

            Text("\(Int(item.minTemperature.rounded()))°")
                .foregroundStyle(.secondary)

            Text("\(Int(item.maxTemperature.rounded()))°")
                .fontWeight(.semibold)
        }
        .padding(16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    DailyForecastSection(items: HomeMockData.weatherDetails.dailyForecast)
        .padding()
}
