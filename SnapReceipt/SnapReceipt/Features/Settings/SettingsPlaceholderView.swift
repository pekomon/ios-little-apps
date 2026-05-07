//
//  SettingsPlaceholderView.swift
//  SnapReceipt
//
//  Created by Pekomon on 7.5.2026.
//

import SwiftUI

struct SettingsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Preferences") {
                    settingRow(
                        title: "Default currency",
                        detail: "Will be configurable when parsing preferences land."
                    )
                    settingRow(
                        title: "Image quality",
                        detail: "Future capture tuning for faster OCR vs sharper scans."
                    )
                }

                Section("About") {
                    settingRow(
                        title: "Why local first?",
                        detail: "Receipt images and extracted fields are intended to stay on device."
                    )
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func settingRow(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsPlaceholderView()
}
