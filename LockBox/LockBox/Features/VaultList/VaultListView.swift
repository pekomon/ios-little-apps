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
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    summaryCards
                    content
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 24)
            }
        }
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
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Vault")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Your local entries are unlocked and ready. Add new entries directly into the live vault.")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 16)

                Button {
                    entryEditorViewModel = viewModel.makeEntryEditorViewModel()
                } label: {
                    Label("New", systemImage: "plus")
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.11, green: 0.15, blue: 0.20))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var summaryCards: some View {
        HStack(spacing: 14) {
            summaryCard(title: "Entries", value: "\(viewModel.entries.count)", systemImage: "tray.full.fill")
            summaryCard(title: "Sensitive", value: "\(sensitiveEntryCount)", systemImage: "lock.doc.fill")
        }
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

    private var loadingCard: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(.white)
            Text("Loading vault entries...")
                .foregroundStyle(.white)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
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
    }

    private var emptyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your vault is empty")
                .font(.headline)
                .foregroundStyle(.white)

            Text("The repository and persistence layers are active, but there are no entries yet.")
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func entryCard(_ entry: VaultEntry) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.metadata.title)
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.11, green: 0.15, blue: 0.20))

                    Text(entry.metadata.kind.rawValue.capitalized)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.black.opacity(0.55))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text(entry.metadata.updatedAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.black.opacity(0.45))

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.black.opacity(0.35))
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
                        Spacer()
                        Text(displayValue(for: field))
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(Color(red: 0.11, green: 0.15, blue: 0.20))
                            .lineLimit(1)
                    }
                }
            }

            if !entry.notes.isEmpty {
                Text(entry.notes)
                    .font(.footnote)
                    .foregroundStyle(.black.opacity(0.65))
                    .lineLimit(2)
            }
        }
        .padding(22)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
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
        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
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

    private var sensitiveEntryCount: Int {
        viewModel.entries.filter { entry in
            entry.fields.contains(where: \.kind.isSensitive)
        }.count
    }

    private func displayValue(for field: VaultEntryField) -> String {
        field.kind.isSensitive ? "••••••••" : field.value
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
