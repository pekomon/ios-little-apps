//
//  EntryDetailView.swift
//  LockBox
//
//  Created by Pekomon on 26.4.2026.
//

import SwiftUI

struct EntryDetailView: View {
    let viewModel: VaultListViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var entry: VaultEntry
    @State private var entryEditorViewModel: EntryEditorViewModel?
    @State private var isShowingDeleteConfirmation = false
    @State private var isDeleting = false
    @State private var errorMessage: String?

    init(entry: VaultEntry, viewModel: VaultListViewModel) {
        self.viewModel = viewModel
        _entry = State(initialValue: entry)
    }

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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    entryEditorViewModel = viewModel.makeEntryEditorViewModel(for: entry)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            deleteBar
        }
        .sheet(item: $entryEditorViewModel) { entryEditorViewModel in
            EntryEditorView(viewModel: entryEditorViewModel) {
                do {
                    entry = try await viewModel.refreshEntry(id: entry.id)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
        .confirmationDialog(
            "Delete this entry?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Entry", role: .destructive) {
                Task {
                    await deleteEntry()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently removes the entry from local storage.")
        }
        .alert("Action Failed", isPresented: errorAlertIsPresented, actions: {
            Button("OK") {
                errorMessage = nil
            }
        }, message: {
            Text(errorMessage ?? "")
        })
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

    private var deleteBar: some View {
        VStack(spacing: 0) {
            Divider()
                .overlay(.white.opacity(0.15))

            Button(role: .destructive) {
                isShowingDeleteConfirmation = true
            } label: {
                if isDeleting {
                    ProgressView()
                        .tint(.red)
                        .frame(maxWidth: .infinity)
                } else {
                    Label("Delete Entry", systemImage: "trash")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background(.thinMaterial)
            .disabled(isDeleting)
        }
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
        field.value
    }

    private func deleteEntry() async {
        guard !isDeleting else { return }

        isDeleting = true
        do {
            try await viewModel.deleteEntry(id: entry.id)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isDeleting = false
    }

    private var errorAlertIsPresented: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )
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
        ),
        viewModel: VaultListViewModel(
            repository: DefaultVaultRepository(
                metadataStore: JSONFileVaultEntryMetadataStore(),
                secureValueStore: KeychainSecureValueStore()
            )
        )
    )
}
