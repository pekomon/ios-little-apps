//
//  EntryEditorView.swift
//  LockBox
//
//  Created by Pekomon on 21.4.2026.
//

import SwiftUI

struct EntryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: EntryEditorViewModel
    let onSaved: @MainActor () async -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(viewModel.screenTitle)
                            .font(.title2.weight(.bold))

                        Text("Entries stay on device. Give this record a clear title and only fill the fields that matter.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .accessibilityElement(children: .combine)

                Section("Entry") {
                    TextField("Title", text: $viewModel.title)
                        .textInputAutocapitalization(.words)
                        .accessibilityLabel("Entry title")
                        .accessibilityHint("Provide a clear name for this vault entry.")

                    Picker("Type", selection: $viewModel.kind) {
                        ForEach(VaultEntryKind.allCases, id: \.self) { kind in
                            Text(kind.rawValue.capitalized)
                                .tag(kind)
                        }
                    }
                    .accessibilityHint("Chooses the kind of vault entry and updates the suggested fields.")
                }

                Section("Fields") {
                    fieldRow(viewModel.primaryLabel, text: $viewModel.primaryValue, keyboard: viewModel.primaryKeyboard)
                    fieldRow(viewModel.secondaryLabel, text: $viewModel.secondaryValue, keyboard: viewModel.secondaryKeyboard)
                    fieldRow(viewModel.tertiaryLabel, text: $viewModel.tertiaryValue, keyboard: viewModel.tertiaryKeyboard)
                }

                Section("Notes") {
                    TextField("Optional notes", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(4...8)
                        .accessibilityLabel("Notes")
                        .accessibilityHint("Optional freeform notes for this entry.")
                }

                Section {
                    TextField("Comma-separated tags", text: $viewModel.tagsText)
                        .accessibilityLabel("Tags")
                        .accessibilityHint("Separate tags with commas.")
                } header: {
                    Text("Tags")
                } footer: {
                    Text("Use short tags like work, finance, or shared to make entries easier to scan later.")
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(viewModel.screenTitle)
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.isSaving ? "Saving..." : viewModel.saveButtonTitle) {
                        Task {
                            let didSave = await viewModel.save()
                            if didSave {
                                await onSaved()
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
    }

    @ViewBuilder
    private func fieldRow(_ title: String, text: Binding<String>, keyboard: EntryEditorKeyboard) -> some View {
        TextField(title, text: text)
            .textInputAutocapitalization(keyboard == .default ? .sentences : .never)
            .autocorrectionDisabled(keyboard != .default)
            .keyboardType(keyboardType(for: keyboard))
            .accessibilityLabel(title)
    }

    private func keyboardType(for keyboard: EntryEditorKeyboard) -> UIKeyboardType {
        switch keyboard {
        case .default:
            return .default
        case .email:
            return .emailAddress
        case .url:
            return .URL
        case .phone:
            return .phonePad
        }
    }
}
