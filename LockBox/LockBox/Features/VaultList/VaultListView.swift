//
//  VaultListView.swift
//  LockBox
//
//  Created by Pekomon on 20.4.2026.
//

import SwiftUI

struct VaultListView: View {
    @Bindable var viewModel: VaultListViewModel
    @State private var entryEditorViewModel: EntryEditorViewModel?

    var body: some View {
        NavigationStack {
            ZStack {
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

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        content
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        entryEditorViewModel = viewModel.makeEntryEditorViewModel()
                    } label: {
                        Label("New", systemImage: "plus")
                            .font(.headline)
                    }
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            await viewModel.loadIfNeeded()
        }
        .sheet(item: $entryEditorViewModel) { entryEditorViewModel in
            EntryEditorView(viewModel: entryEditorViewModel) {
                await viewModel.reload()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Vault")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Your local entries are unlocked and ready. Review, update, or remove items without leaving the live vault.")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.82))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 16)

                Label("Local only", systemImage: "externaldrive.badge.checkmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.82))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.08), in: Capsule())
                    .accessibilityLabel("Stored locally on this device")
            }

            summaryCards
        }
        .padding(22)
        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    private var summaryCards: some View {
        HStack(spacing: 14) {
            summaryCard(title: "Entries", value: "\(viewModel.entries.count)", systemImage: "tray.full.fill")
            summaryCard(title: "Sensitive", value: "\(sensitiveEntryCount)", systemImage: "lock.doc.fill")
        }
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            loadingCard
        } else if let errorMessage = viewModel.errorMessage {
            errorCard(message: errorMessage)
        } else if viewModel.entries.isEmpty {
            emptyCard
        } else {
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader(
                    title: "Recent entries",
                    subtitle: "Sensitive values stay redacted in the list until you open an item."
                )

                LazyVStack(spacing: 14) {
                    ForEach(viewModel.entries) { entry in
                        NavigationLink {
                            EntryDetailView(entry: entry, viewModel: viewModel)
                        } label: {
                            entryCard(entry)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var loadingCard: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(.white)
                .accessibilityHidden(true)
            Text("Loading vault entries...")
                .foregroundStyle(.white)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private func errorCard(message: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Vault couldn’t load", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundStyle(.white)

            Text(message)
                .foregroundStyle(.white.opacity(0.82))

            Button("Try Again") {
                Task {
                    await viewModel.reload()
                }
            }
            .buttonStyle(.plain)
            .font(.headline)
            .foregroundStyle(Color(red: 0.11, green: 0.15, blue: 0.20))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.25), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    private var emptyCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your vault is empty")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Local storage is ready, but there are no entries yet. Start by adding a login, note, card, or identity record.")
                .foregroundStyle(.white.opacity(0.8))

            Button {
                entryEditorViewModel = viewModel.makeEntryEditorViewModel()
            } label: {
                Label("Create your first entry", systemImage: "plus")
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.11, green: 0.15, blue: 0.20))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens the editor to add your first vault entry.")
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    private func entryCard(_ entry: VaultEntry) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.metadata.title)
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.11, green: 0.15, blue: 0.20))
                        .lineLimit(2)

                    Label(entry.metadata.kind.displayName, systemImage: entry.metadata.kind.symbolName)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.black.opacity(0.55))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text(entry.metadata.updatedAt.lockBoxListDate)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.black.opacity(0.45))

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.black.opacity(0.35))
                        .accessibilityHidden(true)
                }
            }

            if !entry.metadata.tags.isEmpty {
                tagRow(entry.metadata.tags)
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(entry.fields.prefix(3)) { field in
                    HStack {
                        Text(field.label)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.black.opacity(0.55))
                            .lineLimit(1)
                        Spacer()
                        Text(displayValue(for: field))
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(Color(red: 0.11, green: 0.15, blue: 0.20))
                            .lineLimit(1)
                            .truncationMode(field.kind.prefersMiddleTruncation ? .middle : .tail)
                    }
                }
            }

            if !entry.notes.isEmpty {
                Text(entry.notes)
                    .font(.footnote)
                    .foregroundStyle(.black.opacity(0.65))
                    .lineLimit(2)
                    .padding(.top, 2)
            }
        }
        .padding(22)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(entryAccessibilityLabel(entry))
        .accessibilityValue(entryAccessibilityValue(entry))
        .accessibilityHint("Opens entry details.")
    }

    private func summaryCard(title: String, value: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(0.78))

            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value)
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

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.76))
        }
    }

    private var sensitiveEntryCount: Int {
        viewModel.entries.filter { entry in
            entry.fields.contains(where: \.kind.isSensitive)
        }.count
    }

    private func displayValue(for field: VaultEntryField) -> String {
        field.kind.isSensitive ? "••••••••" : field.value
    }

    private func entryAccessibilityLabel(_ entry: VaultEntry) -> String {
        "\(entry.metadata.title), \(entry.metadata.kind.displayName)"
    }

    private func entryAccessibilityValue(_ entry: VaultEntry) -> String {
        var components = ["Updated \(entry.metadata.updatedAt.lockBoxListDate)"]

        if !entry.metadata.tags.isEmpty {
            components.append("Tags: \(entry.metadata.tags.joined(separator: ", "))")
        }

        let fieldSummary = entry.fields.prefix(3).map { field in
            if field.kind.isSensitive {
                return "\(field.label), hidden"
            }
            return "\(field.label), \(field.value)"
        }

        if !fieldSummary.isEmpty {
            components.append(fieldSummary.joined(separator: ". "))
        }

        if !entry.notes.isEmpty {
            components.append("Includes notes")
        }

        return components.joined(separator: ". ")
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
    var prefersMiddleTruncation: Bool {
        switch self {
        case .emailAddress, .url:
            return true
        case .username, .password, .oneTimeCode, .phoneNumber, .text:
            return false
        }
    }
}

private extension Date {
    var lockBoxListDate: String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        }

        if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        }

        return formatted(date: .abbreviated, time: .omitted)
    }
}

#Preview {
    VaultListView(
        viewModel: VaultListViewModel(
            repository: DefaultVaultRepository(
                metadataStore: JSONFileVaultEntryMetadataStore(),
                secureValueStore: KeychainSecureValueStore()
            )
        )
    )
}
