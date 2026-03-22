//
//  HourlyForecastSection.swift
//  Weatherly
//
//  Created by Pekomon on 22.3.2026.
//
	

import SwiftUI

struct HourlyForecastSection: View {
    let items: [HourlyForecast]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hourly Forecast")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(items.prefix(12))) { item in
                        HourlyForecastItemView(item: item)
                    }
                }
            }
        }
    }
}

private struct HourlyForecastItemView: View {
    let item: HourlyForecast

    var body: some View {
        VStack(spacing: 10) {
            Text(item.date, format: .dateTime.hour())
                .font(.subheadline)

            Image(systemName: item.symbolName)
                .font(.title3)
                .symbolRenderingMode(.multicolor)

            Text("\(Int(item.temperature.rounded()))°")
                .fontWeight(.medium)
        }
        .frame(width: 72)
        .padding(.vertical, 16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    HourlyForecastSection(items: HomeMockData.weatherDetails.hourlyForecast)
        .padding()
}
