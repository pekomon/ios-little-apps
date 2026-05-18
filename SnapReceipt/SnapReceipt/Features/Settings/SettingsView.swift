//
//  SettingsView.swift
//  SnapReceipt
//
//  Created by Codex on 18.5.2026.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(SnapReceiptSettings.defaultCurrencyKey) private var defaultCurrency = SnapReceiptSettings.defaultCurrency()
    @AppStorage(SnapReceiptSettings.imageQualityKey) private var imageQualityRawValue = ReceiptImageQuality.balanced.rawValue

    private let persistenceLocation = ReceiptPersistenceLocation()

    private var imageQuality: ReceiptImageQuality {
        get { ReceiptImageQuality(rawValue: imageQualityRawValue) ?? .balanced }
        nonmutating set { imageQualityRawValue = newValue.rawValue }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Receipt Defaults") {
                    Picker("Default Currency", selection: $defaultCurrency) {
                        ForEach(SnapReceiptSettings.supportedCurrencies, id: \.self) { currencyCode in
                            Text(currencyCode)
                                .tag(currencyCode)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Used as the starting value in receipt review when OCR does not detect a currency.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 2)
                    .accessibilityHidden(true)
                }

                Section("Saved Image Quality") {
                    Picker("Image Quality", selection: imageQualityBinding) {
                        ForEach(ReceiptImageQuality.allCases) { quality in
                            Text(quality.title)
                                .tag(quality)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(imageQuality.detail)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Current JPEG compression: \(compressionSummary(for: imageQuality)).")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 2)
                    .accessibilityHidden(true)
                }

                Section("Local Storage") {
                    settingsRow(
                        title: "Storage Model",
                        detail: "Receipt metadata and saved images stay on this device in Application Support."
                    )
                    settingsRow(
                        title: "Receipts File",
                        detail: persistenceLocation.receiptsFileURL.lastPathComponent
                    )
                    settingsRow(
                        title: "Images Folder",
                        detail: persistenceLocation.imagesDirectoryURL.lastPathComponent
                    )
                }

                Section("About SnapReceipt") {
                    settingsRow(
                        title: "Why local first?",
                        detail: "Receipt images, OCR text, and extracted fields remain in local app storage instead of being uploaded to a backend."
                    )
                    settingsRow(
                        title: "Focus",
                        detail: "Fast receipt capture, OCR review, and practical expense record keeping without cloud complexity."
                    )
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var imageQualityBinding: Binding<ReceiptImageQuality> {
        Binding(
            get: { imageQuality },
            set: { imageQuality = $0 }
        )
    }

    private func settingsRow(title: String, detail: String) -> some View {
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

    private func compressionSummary(for quality: ReceiptImageQuality) -> String {
        String(format: "%.2f", quality.compressionQuality)
    }
}

#Preview {
    SettingsView()
}
