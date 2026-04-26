//
//  EntryDetailView.swift
//  LockBox
//
//  Created by Pekomon on 26.4.2026.
//

import SwiftUI

struct EntryDetailView: View {
    let entry: VaultEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                metadataCard
                fieldsCard

                if !entry.notes.isEmpty {
                    notesCard
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 32)
        }
        .navigationTitle(entry.metadata.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.11, blue: 0.16),
                    Color(red: 0.12, green: 0.17, blue: 0.23),
                    Color(red: 0.78, green: 0.71, blue: 0.56)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(entry.metadata.kind.rawValue.capitalized)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(0.78))

            Text(entry.metadata.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            if !entry.metadata.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entry.metadata.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color(red: 0.11, green: 0.15, blue: 0.20))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.82), in: Capsule())
                        }
                    }
                }
            }
        }
    }

    private var metadataCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardTitle("Metadata")
            detailRow("Created", value: entry.metadata.createdAt.formatted(date: .abbreviated, time: .shortened))
            detailRow("Updated", value: entry.metadata.updatedAt.formatted(date: .abbreviated, time: .shortened))
            detailRow("Fields", value: "\(entry.fields.count)")
        }
        .padding(22)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private var fieldsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardTitle("Fields")

            ForEach(entry.fields) { field in
                VStack(alignment: .leading, spacing: 6) {
                    Text(field.label)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.black.opacity(0.55))

                    Text(displayValue(for: field))
                        .font(.body)
                        .foregroundStyle(Color(red: 0.11, green: 0.15, blue: 0.20))
                        .textSelection(.enabled)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
            }
        }
        .padding(22)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardTitle("Notes")

            Text(entry.notes)
                .font(.body)
                .foregroundStyle(Color(red: 0.11, green: 0.15, blue: 0.20))
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
        .padding(22)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private func cardTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(Color(red: 0.11, green: 0.15, blue: 0.20))
    }

    private func detailRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.black.opacity(0.55))
            Spacer()
            Text(value)
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color(red: 0.11, green: 0.15, blue: 0.20))
        }
    }

    private func displayValue(for field: VaultEntryField) -> String {
        field.kind.isSensitive ? field.value : field.value
    }
}

#Preview {
    EntryDetailView(
        entry: VaultEntry(
            metadata: VaultEntryMetadata(
                kind: .login,
                title: "Fastmail",
                tags: ["email", "personal"]
            ),
            fields: [
                VaultEntryField(label: "Email", value: "pekka@example.com", kind: .emailAddress),
                VaultEntryField(label: "Password", value: "correct-horse-battery-staple", kind: .password)
            ],
            notes: "Primary personal mailbox."
        )
    )
}
