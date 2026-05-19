//
//  ReceiptReviewView.swift
//  SnapReceipt
//
//  Created by Pekomon on 15.5.2026.
//

import SwiftUI

struct ReceiptReviewView: View {
    let asset: ImportedReceiptAsset
    let sourceDescription: String
    let onSave: @MainActor (ReceiptReviewDraft) async throws -> Void

    @State private var merchantName: String
    @State private var purchaseDate: Date
    @State private var includesPurchaseDate: Bool
    @State private var totalAmountText: String
    @State private var currencyCode: String
    @State private var notes: String
    @State private var rawText: String
    private let source: ReceiptSource
    @State private var isSaving = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    init(
        asset: ImportedReceiptAsset,
        sourceDescription: String,
        initialDraft: ReceiptReviewDraft,
        onSave: @escaping @MainActor (ReceiptReviewDraft) async throws -> Void
    ) {
        self.asset = asset
        self.sourceDescription = sourceDescription
        self.onSave = onSave
        self.source = initialDraft.source
        _merchantName = State(initialValue: initialDraft.merchantName)
        _purchaseDate = State(initialValue: initialDraft.purchaseDate)
        _includesPurchaseDate = State(initialValue: initialDraft.includesPurchaseDate)
        _totalAmountText = State(initialValue: initialDraft.totalAmountText)
        _currencyCode = State(initialValue: initialDraft.currencyCode)
        _notes = State(initialValue: initialDraft.notes)
        _rawText = State(initialValue: initialDraft.rawText)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    previewCard
                    reviewSummaryCard
                    editorSection
                    rawTextSection
                    saveGuidanceCard
                }
                .padding(20)
                .padding(.bottom, 28)
            }
            .background(backgroundGradient.ignoresSafeArea())
            .navigationTitle("Review Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let draftToSave = makeDraft()
                        Task { @MainActor in
                            await saveReceipt(using: draftToSave)
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save Receipt")
                        }
                    }
                    .disabled(merchantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                }
            }
        }
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                Image(uiImage: asset.uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 116, height: 148)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(.white.opacity(0.12), lineWidth: 1)
                    }
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Confirm fields before saving")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(sourceDescription)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.78))

                    Text(asset.fileName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    if let sizeDescription = asset.imageSizeDescription {
                        Text(sizeDescription)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }

            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(.subheadline)
                    .foregroundStyle(Color(red: 1.0, green: 0.83, blue: 0.37))
            }
        }
        .padding(24)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Receipt review preview. Source: \(sourceDescription). File name: \(asset.fileName).")
    }

    private var reviewSummaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Save Preview")
                    .font(.headline)

                Spacer(minLength: 12)

                Text(validationStatusTitle)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(validationIssues.isEmpty ? Color(red: 0.18, green: 0.60, blue: 0.42) : .orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.58), in: Capsule())
            }

            HStack(spacing: 10) {
                reviewMetricChip(title: "Merchant", value: trimmedMerchantNameForDisplay)
                reviewMetricChip(title: "Amount", value: totalAmountForDisplay)
                reviewMetricChip(title: "Currency", value: currencyForDisplay)
            }

            if !validationIssues.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(validationIssues, id: \.self) { issue in
                        Label(issue, systemImage: "exclamationmark.circle.fill")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private var editorSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                title: "Editable Fields",
                subtitle: "Adjust OCR suggestions so the saved receipt looks right in the library."
            )

            VStack(alignment: .leading, spacing: 14) {
                labeledField(title: "Merchant") {
                    TextField("Merchant name", text: $merchantName)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                }

                Toggle("Include purchase date", isOn: $includesPurchaseDate)
                    .font(.subheadline.weight(.medium))
                    .accessibilityHint("Turn this off if the receipt date could not be identified.")

                if includesPurchaseDate {
                    DatePicker(
                        "Purchase Date",
                        selection: $purchaseDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                }

                labeledField(title: "Total") {
                    TextField("0.00", text: $totalAmountText)
                        .keyboardType(.decimalPad)
                }

                labeledField(title: "Currency") {
                    TextField("EUR", text: $currencyCode)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                }

                labeledField(title: "Notes") {
                    TextField("Optional note", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .accessibilityElement(children: .contain)
        }
    }

    private var rawTextSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                title: "Recognized Text",
                subtitle: "Reference OCR output while you review the extracted receipt fields."
            )

            Text(rawText.isEmpty ? "No OCR text was detected for this receipt image." : rawText)
                .font(.system(.footnote, design: .monospaced))
                .foregroundStyle(rawText.isEmpty ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                .accessibilityLabel(rawText.isEmpty ? "No OCR text was detected for this receipt image." : "Recognized text. \(rawText)")
        }
    }

    private var saveGuidanceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Before saving")
                .font(.headline)

            Text("Use the OCR output as reference, fix any missing merchant or total fields, and confirm the purchase date only when it is clearly visible.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func labeledField<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            content()
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func reviewMetricChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(.white.opacity(0.52), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var backgroundGradient: LinearGradient {
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

    private func makeDraft() -> ReceiptReviewDraft {
        ReceiptReviewDraft(
            merchantName: merchantName,
            purchaseDate: purchaseDate,
            includesPurchaseDate: includesPurchaseDate,
            totalAmountText: totalAmountText,
            currencyCode: currencyCode,
            notes: notes,
            rawText: rawText,
            source: source
        )
    }

    private func saveReceipt(using draftToSave: ReceiptReviewDraft) async {
        isSaving = true
        errorMessage = nil

        do {
            try await onSave(draftToSave)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }

    private var validationIssues: [String] {
        var issues: [String] = []

        if trimmedMerchantNameForDisplay == "Missing" {
            issues.append("Add a merchant name before saving.")
        }

        if !totalAmountText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, makeDraft().parsedTotalAmount == nil {
            issues.append("Total amount format should use digits like 18.40.")
        }

        if !currencyCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           currencyCode.trimmingCharacters(in: .whitespacesAndNewlines).count < 3 {
            issues.append("Currency code should be a 3-letter code such as EUR.")
        }

        return issues
    }

    private var validationStatusTitle: String {
        validationIssues.isEmpty ? "Ready to Save" : "Needs Review"
    }

    private var trimmedMerchantNameForDisplay: String {
        let value = merchantName.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? "Missing" : value
    }

    private var totalAmountForDisplay: String {
        let value = totalAmountText.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? "Optional" : value
    }

    private var currencyForDisplay: String {
        let value = currencyCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        return value.isEmpty ? "Optional" : value
    }
}

#Preview {
    ReceiptReviewView(
        asset: ImportedReceiptAsset(
            uiImage: UIImage(systemName: "doc.text.image") ?? UIImage(),
            pixelSize: CGSize(width: 1200, height: 1800),
            fileName: "LunchReceipt.jpg",
            source: .photoLibrary
        ),
        sourceDescription: "Imported from the user's photo library.",
        initialDraft: ReceiptReviewDraft(
            merchantName: "Cafe Esplanad",
            purchaseDate: .now,
            includesPurchaseDate: true,
            totalAmountText: "18.40",
            currencyCode: "EUR",
            notes: "",
            rawText: "Cafe Esplanad\nLunch Menu\nTotal EUR 18.40",
            source: .photoLibrary
        )
    ) { _ in }
}
