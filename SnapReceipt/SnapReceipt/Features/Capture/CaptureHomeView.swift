//
//  CaptureHomeView.swift
//  SnapReceipt
//
//  Created by Pekomon on 7.5.2026.
//

import SwiftUI

struct CaptureHomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        heroCard
                        quickActions
                        processPreview
                    }
                    .padding(24)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle("SnapReceipt")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Capture receipts in one pass")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Scan, extract, and review expense details locally before anything is saved.")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.84))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 16)

                Label("Local first", systemImage: "internaldrive.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.84))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.10), in: Capsule())
            }

            HStack(spacing: 14) {
                summaryPill(title: "Stage", value: "Scaffold")
                summaryPill(title: "Focus", value: "OCR Flow")
            }

            Button {
            } label: {
                Label("Capture Receipt", systemImage: "camera")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0.97, green: 0.62, blue: 0.22))
        }
        .padding(24)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Next inputs", subtitle: "The capture layer will support both live scanning and importing an existing image.")

            HStack(spacing: 14) {
                actionCard(
                    title: "Camera Scan",
                    detail: "Frame a full receipt and extract line items from the image.",
                    systemImage: "viewfinder"
                )

                actionCard(
                    title: "Photo Import",
                    detail: "Bring in a saved receipt image for parsing and cleanup.",
                    systemImage: "photo.on.rectangle"
                )
            }
        }
    }

    private var processPreview: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Review flow", subtitle: "Static for now, but this is the structure later tasks will fill in.")

            VStack(spacing: 12) {
                processRow(step: "1", title: "Recognize text", detail: "Vision-based OCR will pull raw receipt text from the captured image.")
                processRow(step: "2", title: "Parse key fields", detail: "Merchant, date, currency, and total will be suggested automatically.")
                processRow(step: "3", title: "Confirm before save", detail: "The user will edit any mistakes before a receipt enters local storage.")
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
    }

    private func summaryPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.62))
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.black.opacity(0.14), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func actionCard(title: String, detail: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color(red: 0.97, green: 0.62, blue: 0.22))

            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func processRow(step: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(step)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(Color(red: 0.10, green: 0.18, blue: 0.28), in: Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title3.weight(.bold))
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.16, blue: 0.24),
                Color(red: 0.18, green: 0.27, blue: 0.36),
                Color(red: 0.96, green: 0.79, blue: 0.57)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    CaptureHomeView()
}
