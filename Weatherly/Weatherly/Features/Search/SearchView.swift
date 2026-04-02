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
        let trimmedQuery = viewModel.state.query.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedQuery.isEmpty {
            ContentUnavailableView {
                Label("Search for a City", systemImage: "magnifyingglass")
            } description: {
                Text("Enter a city name to find weather locations around the world.")
            }
        } else if trimmedQuery.count < 2 {
            ContentUnavailableView {
                Label("Keep Typing", systemImage: "text.cursor")
            } description: {
                Text("Type at least 2 characters to search for a location.")
            }
        } else if !viewModel.state.results.isEmpty {
            resultsList
        } else if viewModel.state.isLoading {
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
        } else {
            ContentUnavailableView {
                Label("No Matching Locations", systemImage: "mappin.slash")
            } description: {
                Text("Try another city name or a broader place search.")
            }
        }
    }

    private var resultsList: some View {
        List(viewModel.state.results) { location in
            SearchResultRow(location: location)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .overlay(alignment: .top) {
            if viewModel.state.isLoading {
                ProgressView("Searching...")
                    .controlSize(.small)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.top, 12)
            }
        }
    }
}

private struct SearchResultRow: View {
    let location: Location

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(location.name)
                .font(.headline)

            if let country = location.country, !country.isEmpty {
                Text(country)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    SearchView()
}
