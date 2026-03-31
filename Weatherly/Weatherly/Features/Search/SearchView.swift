//
//  SearchView.swift
//  Weatherly
//
//  Created by Pekomon on 15.3.2026.
//
	

import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("Search")
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
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.state.isLoading {
            VStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)

                Text("Searching locations...")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = viewModel.state.errorMessage {
            ContentUnavailableView {
                Label("Search Unavailable", systemImage: "exclamationmark.magnifyingglass")
            } description: {
                Text(errorMessage)
            }
        } else if viewModel.state.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ContentUnavailableView {
                Label("Search for a City", systemImage: "magnifyingglass")
            } description: {
                Text("Enter a city name to look up weather locations.")
            }
        } else if viewModel.state.results.isEmpty {
            ContentUnavailableView {
                Label("No Matching Locations", systemImage: "mappin.slash")
            } description: {
                Text("Try a different city name or adjust your search.")
            }
        } else {
            List(viewModel.state.results) { location in
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.headline)

                    if let country = location.country, !country.isEmpty {
                        Text(country)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
                .listRowBackground(Color(.secondarySystemGroupedBackground))
            }
            .scrollContentBackground(.hidden)
        }
    }
}

#Preview {
    SearchView()
}
