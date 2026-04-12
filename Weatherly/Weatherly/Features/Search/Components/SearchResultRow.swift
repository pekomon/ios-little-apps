//
//  SearchResultRow.swift
//  Weatherly
//
//  Created by Pekomon on 2.4.2026.
//

import SwiftUI

struct SearchResultRow: View {
    let location: Location

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 24))
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color.white.opacity(0.95), Color.blue.opacity(0.75))
                .frame(width: 36, height: 36)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if let country = location.country, !country.isEmpty {
                    Text(country)
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
    SearchResultRow(
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
                Color.blue.opacity(0.65),
                Color.indigo.opacity(0.55)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
