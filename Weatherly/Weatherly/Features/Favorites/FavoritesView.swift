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
            VStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)

                Text("Loading favorites...")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .empty:
            emptyState

        case .loaded(let locations):
            favoritesList(locations)
        }
    }

    private var emptyState: some View {
        VStack {
            Spacer(minLength: 24)

            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.16))
                        .frame(width: 68, height: 68)

                    Image(systemName: "star.bubble.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.orange)
                }

                VStack(spacing: 8) {
                    Text("No Favorite Places Yet")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text("Save cities you want to revisit and they’ll appear here for quick access.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 30)
            .background(.ultraThinMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .padding(.horizontal, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func favoritesList(_ locations: [Location]) -> some View {
        List {
            Section {
                ForEach(locations) { location in
                    Button {
                        selectedLocation = location
                    } label: {
                        FavoriteLocationRow(location: location)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.removeFavorite(location)
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                }
            } header: {
                HStack(alignment: .center) {
                    Label("Saved Locations", systemImage: "star.fill")
                        .font(.headline)

                    Spacer()

                    Text(locationCountText(for: locations.count))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .textCase(nil)
            }
        }
        .listStyle(.plain)
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
