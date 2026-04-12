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
                RoundedRectangle(cornerRadius: 18)
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
                    .frame(width: 48, height: 48)

                Image(systemName: "star.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .accessibilityHidden(true)
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

            VStack(alignment: .trailing, spacing: 6) {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)

                Text("Weather")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(.regularMaterial)
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLocationDescription)
    }

    private var accessibilityLocationDescription: String {
        if let country = location.country, !country.isEmpty {
            return "\(location.name), \(country)"
        }

        return location.name
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
