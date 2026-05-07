//
//  ReceiptsOverviewView.swift
//  SnapReceipt
//
//  Created by Pekomon on 7.5.2026.
//

import SwiftUI

struct ReceiptsOverviewView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Saved Receipts") {
                    placeholderRow(
                        title: "No receipts yet",
                        subtitle: "Captured receipts will appear here after review and save."
                    )
                }

                Section("Planned metadata") {
                    placeholderRow(title: "Merchant", subtitle: "Suggested from OCR text")
                    placeholderRow(title: "Date", subtitle: "Parsed and editable")
                    placeholderRow(title: "Total", subtitle: "Validated before saving")
                }
            }
            .navigationTitle("Receipts")
        }
    }

    private func placeholderRow(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ReceiptsOverviewView()
}
