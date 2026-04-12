//
//  SearchLocationWeatherView.swift
//  Weatherly
//
//  Created by Pekomon on 3.4.2026.
//

import SwiftUI

struct SearchLocationWeatherView: View {
    @State private var viewModel: SearchLocationWeatherViewModel

    init(location: Location) {
        _viewModel = State(initialValue: SearchLocationWeatherViewModel(location: location))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                content
            }
            .navigationTitle("Weather")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.toggleFavorite()
                    } label: {
                        Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                            .foregroundStyle(viewModel.isFavorite ? Color.yellow : Color.primary)
                    }
                    .accessibilityLabel(viewModel.isFavorite ? "Remove from Favorites" : "Save to Favorites")
                    .accessibilityValue(viewModel.isFavorite ? "Saved" : "Not saved")
                }
            }
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
            centeredStateCard {
                AppStateCard(
                    title: "Loading Forecast",
                    message: "Fetching current conditions and forecast details for this location.",
                    systemImage: "cloud.sun.fill",
                    tint: .white
                ) {
                    ProgressView()
                        .controlSize(.regular)
                }
            }

        case .failed(let message):
            centeredStateCard {
                AppStateCard(
                    title: "Unable to Load Forecast",
                    message: message,
                    systemImage: "cloud.slash",
                    tint: .white
                ) {
                    Button {
                        Task {
                            await viewModel.loadWeather()
                        }
                    } label: {
                        Label("Try Again", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.white.opacity(0.18))
                }
            }

        case .loaded(let weather):
            ScrollView {
                VStack(spacing: 18) {
                    CurrentWeatherCard(weather: weather)
                    WeatherMetricGrid(weather: weather)
                    HourlyForecastSection(items: weather.hourlyForecast)
                    DailyForecastSection(items: weather.dailyForecast)
                }
                .padding()
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
    }

    private func centeredStateCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack {
            Spacer(minLength: 24)

            content()
                .padding(.horizontal, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.85),
                Color.indigo.opacity(0.75),
                Color.cyan.opacity(0.45)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    SearchLocationWeatherView(location: HomeMockData.helsinki)
        .environment(SettingsViewModel())
}
