//
//  RootView.swift
//  Weatherly
//
//  Created by Pekomon on 15.3.2026.
//

import SwiftUI

struct RootView: View {
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
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    RootView()
}
