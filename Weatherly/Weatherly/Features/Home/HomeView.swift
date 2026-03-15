//
//  HomeView.swift
//  Weatherly
//
//  Created by Pekomon on 15.3.2026.
//
	

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            Text("Home")
                .navigationTitle("Weather")
        }
    }
}

#Preview {
    HomeView()
}
