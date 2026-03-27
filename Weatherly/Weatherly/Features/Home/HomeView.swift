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
            ZStack {
                backgroundGradient

                content
            }
            .navigationTitle("Weather")
            .navigationBarTitleDisplayMode(.large)
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
                VStack(spacing: 16) {
                    ProgressView()
                        .controlSize(.large)

                    Text("Loading weather...")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

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
                    .buttonStyle(.borderedProminent)
                }

            case .loaded(let weather):
                ScrollView {
                    VStack(spacing: 20) {
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
        HomeView()
    }
