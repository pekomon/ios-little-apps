//
//  SearchView.swift
//  Weatherly
//
//  Created by Pekomon on 15.3.2026.
//

import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @State private var selectedLocation: Location?

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                content
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: Binding(
                    get: { viewModel.state.query },
                    set: { viewModel.updateQuery($0) }
                ),
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search cities for weather"
            )
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .sheet(item: $selectedLocation) { location in
                SearchLocationWeatherView(location: location)
                    .presentationDragIndicator(.visible)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        let trimmedQuery = viewModel.state.query.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedQuery.isEmpty {
            recentSearchesContent
        } else if trimmedQuery.count < 2 {
            stateCard(
                title: "Keep Typing",
                message: "Type at least 2 characters to search for a location.",
                systemImage: "text.cursor"
            )
        } else if !viewModel.state.results.isEmpty {
            resultsList
        } else if viewModel.state.isLoading {
            stateCard(
                title: "Searching Locations",
                message: "Looking up matching places for your weather search.",
                systemImage: "location.magnifyingglass",
                showsProgress: true
            )
        } else if let errorMessage = viewModel.state.errorMessage {
            stateCard(
                title: "Search Unavailable",
                message: errorMessage,
                systemImage: "exclamationmark.magnifyingglass"
            )
        } else {
            stateCard(
                title: "No Matching Locations",
                message: "Try another city name or a broader place search.",
                systemImage: "mappin.slash"
            )
        }
    }

    private var resultsList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                resultsHeader

                LazyVStack(spacing: 12) {
                    ForEach(viewModel.state.results) { location in
                        locationButton(for: location)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .overlay(alignment: .top) {
            if viewModel.state.isLoading {
                ProgressView("Searching...")
                    .controlSize(.small)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.regularMaterial)
                    .clipShape(Capsule())
                    .padding(.top, 12)
            }
        }
    }

    @ViewBuilder
    private var recentSearchesContent: some View {
        if viewModel.state.recentSearches.isEmpty {
            stateCard(
                title: "Search for a City",
                message: "Enter a city name to find weather locations around the world.",
                systemImage: "magnifyingglass"
            )
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    recentSearchesHeader

                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.state.recentSearches) { location in
                            locationButton(for: location)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var recentSearchesHeader: some View {
        HStack(alignment: .center) {
            Label("Recent Searches", systemImage: "clock.arrow.circlepath")
                .font(.headline)

            Spacer()

            Button("Clear") {
                viewModel.clearRecentSearches()
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color.blue)
        }
        .padding(.horizontal, 2)
    }

    private var backgroundGradient: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.blue.opacity(0.20),
                    Color.indigo.opacity(0.14),
                    Color.cyan.opacity(0.08),
                    .clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }

    private var resultsHeader: some View {
        HStack(alignment: .center) {
            Label("Results", systemImage: "mappin.and.ellipse")
                .font(.headline)

            Spacer()

            Text(resultCountText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 2)
    }

    private var resultCountText: String {
        let count = viewModel.state.results.count
        return count == 1 ? "1 place" : "\(count) places"
    }

    private func locationButton(for location: Location) -> some View {
        Button {
            openWeather(for: location)
        } label: {
            SearchResultRow(location: location)
        }
        .buttonStyle(.plain)
    }

    private func openWeather(for location: Location) {
        viewModel.saveRecentSearch(location)
        selectedLocation = location
    }

    private func stateCard(
        title: String,
        message: String,
        systemImage: String,
        showsProgress: Bool = false
    ) -> some View {
        VStack {
            Spacer(minLength: 24)

            SearchStateCard(
                title: title,
                message: message,
                systemImage: systemImage,
                showsProgress: showsProgress
            )
            .padding(.horizontal, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct SearchStateCard: View {
    let title: String
    let message: String
    let systemImage: String
    let showsProgress: Bool

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 62, height: 62)

                Image(systemName: systemImage)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.blue)
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if showsProgress {
                ProgressView()
                    .controlSize(.regular)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .background(.ultraThinMaterial)
        .overlay {
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }
}

#Preview {
    SearchView()
}
