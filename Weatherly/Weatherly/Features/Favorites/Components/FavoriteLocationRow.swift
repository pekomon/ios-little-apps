//
//  FavoriteLocationRow.swift
//  Weatherly
//
//  Created by Pekomon on 4.4.2026.
//

import SwiftUI

struct FavoriteLocationRow: View {
    let location: Location

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.yellow.opacity(0.95),
                                Color.orange.opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 42, height: 42)

                Image(systemName: "star.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if let country = location.country, !country.isEmpty {
                    Text(country)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Saved location")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}

#Preview {
    FavoriteLocationRow(
        location: Location(
            id: "helsinki-fi",
            name: "Helsinki",
            country: "Finland",
            latitude: 60.1699,
            longitude: 24.9384
        )
    )
    .padding()
    .background(
        LinearGradient(
            colors: [
                Color.blue.opacity(0.55),
                Color.indigo.opacity(0.45)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
