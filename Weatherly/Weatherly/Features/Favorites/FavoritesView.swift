//
//  FavoritesView.swift
//  Weatherly
//
//  Created by Pekomon on 15.3.2026.
//

import SwiftUI

struct FavoritesView: View {
    @State private var viewModel: FavoritesViewModel
    @State private var selectedLocation: Location?

    init(viewModel: FavoritesViewModel = FavoritesViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                content
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedLocation, onDismiss: {
                viewModel.loadFavorites(showLoading: false)
            }) { location in
                SearchLocationWeatherView(location: location)
                    .presentationDragIndicator(.visible)
            }
            .task {
                if case .idle = viewModel.state {
                    viewModel.loadFavorites()
                }
            }
            .onAppear {
                if case .idle = viewModel.state {
                    return
                }

                viewModel.loadFavorites(showLoading: false)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            stateCard(
                title: "Loading Favorites",
                message: "Gathering the places you’ve saved for quick weather checks.",
                systemImage: "star.leadinghalf.filled"
            ) {
                ProgressView()
                    .controlSize(.regular)
            }

        case .empty:
            emptyState

        case .loaded(let locations):
            favoritesList(locations)
        }
    }

    private var emptyState: some View {
        stateCard(
            title: "Build Your Favorites List",
            message: "Save cities from Search and they’ll appear here for quick access whenever you want to check the forecast.",
            systemImage: "star.circle.fill"
        ) {
            Label("Tip: open a city and tap the star", systemImage: "sparkles")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.orange)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.orange.opacity(0.12))
                .clipShape(Capsule())
        }
    }

    private func favoritesList(_ locations: [Location]) -> some View {
        List {
            Section {
                favoritesSummaryCard(for: locations.count)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 10, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                ForEach(locations) { location in
                    Button {
                        selectedLocation = location
                    } label: {
                        FavoriteLocationRow(location: location)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Show weather for \(accessibilityLocationDescription(for: location))")
                    .accessibilityHint("Opens detailed weather forecast")
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.removeFavorite(location)
                            HapticFeedback.warning()
                        } label: {
                            Label("Remove \(location.name)", systemImage: "trash")
                        }
                    }
                }
            } header: {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Saved Locations", systemImage: "star.fill")
                        .font(.headline)

                    Text("Open any saved place to view weather details or manage it later.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .textCase(nil)
            }
        }
        .listStyle(.plain)
        .listSectionSpacing(14)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }

    private var backgroundGradient: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.yellow.opacity(0.12),
                    Color.orange.opacity(0.10),
                    Color.blue.opacity(0.08),
                    .clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }

    private func locationCountText(for count: Int) -> String {
        count == 1 ? "1 place" : "\(count) places"
    }

    private func favoritesSummaryCard(for count: Int) -> some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.yellow.opacity(0.9),
                                Color.orange.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)

                Image(systemName: "star.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(locationCountText(for: count))
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("Your saved cities stay here for quick weather check-ins.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(.regularMaterial)
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Saved locations summary")
        .accessibilityValue("\(locationCountText(for: count)). Your saved cities stay here for quick weather check-ins.")
    }

    private func stateCard<Accessory: View>(
        title: String,
        message: String,
        systemImage: String,
        @ViewBuilder accessory: () -> Accessory
    ) -> some View {
        VStack {
            Spacer(minLength: 24)

            AppStateCard(
                title: title,
                message: message,
                systemImage: systemImage,
                tint: .orange
            ) {
                accessory()
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func accessibilityLocationDescription(for location: Location) -> String {
        if let country = location.country, !country.isEmpty {
            return "\(location.name), \(country)"
        }

        return location.name
    }
}

#Preview("Empty") {
    FavoritesView(
        viewModel: FavoritesViewModel(
            favoritesRepository: PreviewFavoritesRepository(locations: [])
        )
    )
}

#Preview("Saved") {
    FavoritesView(
        viewModel: FavoritesViewModel(
            favoritesRepository: PreviewFavoritesRepository(
                locations: [
                    Location(
                        id: "helsinki-fi",
                        name: "Helsinki",
                        country: "Finland",
                        latitude: 60.1699,
                        longitude: 24.9384
                    ),
                    Location(
                        id: "oslo-no",
                        name: "Oslo",
                        country: "Norway",
                        latitude: 59.9139,
                        longitude: 10.7522
                    )
                ]
            )
        )
    )
}

private struct PreviewFavoritesRepository: FavoritesRepository {
    let locations: [Location]

    func fetchFavoriteLocations() -> [Location] {
        locations
    }

    func saveFavorite(_ location: Location) {}

    func removeFavorite(_ location: Location) {}

    func isFavorite(_ location: Location) -> Bool {
        locations.contains(where: { $0.id == location.id })
    }
}
