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
                Section("Entry") {
                    TextField("Title", text: $viewModel.title)

                    Picker("Type", selection: $viewModel.kind) {
                        ForEach(VaultEntryKind.allCases, id: \.self) { kind in
                            Text(kind.rawValue.capitalized)
                                .tag(kind)
                        }
                    }
                }

                Section("Fields") {
                    fieldRow(viewModel.primaryLabel, text: $viewModel.primaryValue, keyboard: viewModel.primaryKeyboard)
                    fieldRow(viewModel.secondaryLabel, text: $viewModel.secondaryValue, keyboard: viewModel.secondaryKeyboard)
                    fieldRow(viewModel.tertiaryLabel, text: $viewModel.tertiaryValue, keyboard: viewModel.tertiaryKeyboard)
                }

                Section("Notes") {
                    TextField("Optional notes", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(4...8)
                }

                Section("Tags") {
                    TextField("Comma-separated tags", text: $viewModel.tagsText)
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
