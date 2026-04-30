//
//  EntryDetailView.swift
//  LockBox
//
//  Created by Pekomon on 26.4.2026.
//

import SwiftUI

struct EntryDetailView: View {
    let viewModel: VaultListViewModel
    private let hapticFeedbackService: any HapticFeedbackServicing

    @Environment(\.dismiss) private var dismiss
    @State private var entry: VaultEntry
    @State private var entryEditorViewModel: EntryEditorViewModel?
    @State private var isShowingDeleteConfirmation = false
    @State private var isDeleting = false
    @State private var errorMessage: String?

    init(
        entry: VaultEntry,
        viewModel: VaultListViewModel,
        hapticFeedbackService: any HapticFeedbackServicing = HapticFeedbackService()
    ) {
        self.viewModel = viewModel
        self.hapticFeedbackService = hapticFeedbackService
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
                .accessibilityHidden(true)

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
            .accessibilityHint("Permanently removes this entry from local storage.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Label(entry.metadata.kind.displayName, systemImage: entry.metadata.kind.symbolName)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.78))

                    Text(entry.metadata.title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Stored locally and protected by the app lock when you leave the vault.")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.78))
                }

                Spacer(minLength: 16)

                VStack(alignment: .trailing, spacing: 8) {
                    Text("Updated")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.66))
                    Text(entry.metadata.updatedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.trailing)
                }
            }

            if !entry.metadata.tags.isEmpty {
                tagRow(entry.metadata.tags)
            }
        }
        .padding(22)
        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .accessibilityElement(children: .contain)
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
        .accessibilityElement(children: .combine)
    }

    private var fieldsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardTitle("Fields")

            ForEach(entry.fields) { field in
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label(field.label, systemImage: field.kind.symbolName)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.black.opacity(0.55))

                        Spacer()

                        if field.kind.isSensitive {
                            Text("Sensitive")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.orange.opacity(0.88))
                        }
                    }

                    Text(displayValue(for: field))
                        .font(field.kind.prefersMonospacedDisplay ? .body.monospaced() : .body)
                        .foregroundStyle(Color(red: 0.11, green: 0.15, blue: 0.20))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .padding(.vertical, 6)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(field.label)
                .accessibilityValue(field.value)
                .accessibilityHint(field.kind.isSensitive ? "Sensitive field." : "")

                if field.id != entry.fields.last?.id {
                    Divider()
                        .overlay(.black.opacity(0.08))
                        .accessibilityHidden(true)
                }
            }
        }
        .padding(22)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .accessibilityElement(children: .contain)
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
        .accessibilityElement(children: .combine)
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

    private func tagRow(_ tags: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
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

    private func deleteEntry() async {
        guard !isDeleting else { return }

        isDeleting = true
        do {
            try await viewModel.deleteEntry(id: entry.id)
            hapticFeedbackService.notify(.success)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            hapticFeedbackService.notify(.error)
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

private extension VaultEntryKind {
    var displayName: String {
        rawValue.capitalized
    }

    var symbolName: String {
        switch self {
        case .login:
            return "person.crop.circle.badge.key"
        case .note:
            return "note.text"
        case .card:
            return "creditcard"
        case .identity:
            return "person.text.rectangle"
        }
    }
}

private extension VaultEntryFieldKind {
    var symbolName: String {
        switch self {
        case .username:
            return "person"
        case .password:
            return "key"
        case .oneTimeCode:
            return "number"
        case .url:
            return "globe"
        case .emailAddress:
            return "envelope"
        case .phoneNumber:
            return "phone"
        case .text:
            return "text.alignleft"
        }
    }

    var prefersMonospacedDisplay: Bool {
        switch self {
        case .password, .oneTimeCode, .phoneNumber:
            return true
        case .username, .url, .emailAddress, .text:
            return false
        }
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
