//
//  RootView.swift
//  Weatherly
//
//  Created by Pekomon on 15.3.2026.
//

import SwiftUI

struct RootView: View {
    private enum Tab: Hashable {
        case home
        case search
        case favorites
        case settings
    }

    private enum DeepLink {
        static let scheme = "weatherly"
        static let homeHost = "home"
    }

    @State private var selectedTab: Tab = .home
    @State private var settingsViewModel = SettingsViewModel()

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(Tab.home)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            SearchView()
                .tag(Tab.search)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            FavoritesView()
                .tag(Tab.favorites)
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
            SettingsView(viewModel: settingsViewModel)
                .tag(Tab.settings)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .environment(settingsViewModel)
        .preferredColorScheme(settingsViewModel.appearancePreference.colorScheme)
        .onOpenURL { url in
            guard
                url.scheme?.lowercased() == DeepLink.scheme,
                url.host?.lowercased() == DeepLink.homeHost
            else {
                return
            }

            selectedTab = .home
        }
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
