//
//  HomeView.swift
//  Weatherly
//
//  Created by Pekomon on 15.3.2026.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Weather")
                .task {
                    if case .idle = viewModel.state {
                        await viewModel.loadWeather()
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading...")

        case .failed(let message):
            ContentUnavailableView {
                Label("Unable to Load Weather", systemImage: "location.slash")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") {
                    Task {
                        await viewModel.loadWeather()
                    }
                }
            }
            
        case .loaded(let weather):
            ScrollView {
                VStack(spacing: 16) {
                    CurrentWeatherCard(weather: weather)
                    WeatherMetricGrid(weather: weather)
                    HourlyForecastSection(items: weather.hourlyForecast)
                    DailyForecastSection(items: weather.dailyForecast)
                }
            }
            .padding()
        }
    }
}

#Preview {
    HomeView()
}
