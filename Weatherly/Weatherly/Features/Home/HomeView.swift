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
            centeredStateCard {
                AppStateCard(
                    title: "Loading Local Weather",
                    message: "Fetching the latest conditions and forecast for your current location.",
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
                    title: "Unable to Load Weather",
                    message: message,
                    systemImage: "location.slash",
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
    HomeView()
        .environment(SettingsViewModel())
}
