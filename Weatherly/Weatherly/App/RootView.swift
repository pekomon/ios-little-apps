//
//  RootView.swift
//  Weatherly
//
//  Created by Pekomon on 15.3.2026.
//

import SwiftUI

struct RootView: View {
    @State private var settingsViewModel = SettingsViewModel()

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
            SettingsView(viewModel: settingsViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .environment(settingsViewModel)
        .preferredColorScheme(settingsViewModel.appearancePreference.colorScheme)
    }
}

private extension AppAppearancePreference {
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            nil
        case .light:
            .light
        case .dark:
            .dark
        }
    }
}

#Preview {
    RootView()
}
