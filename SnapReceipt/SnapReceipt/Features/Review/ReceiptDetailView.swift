//
//  ReceiptDetailView.swift
//  SnapReceipt
//
//  Created by Pekomon on 15.5.2026.
//

import SwiftUI

struct ReceiptDetailView: View {
    let receipt: Receipt

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                summaryCard

                if let imageFileName = receipt.imageFileName {
                    receiptImageSection(fileName: imageFileName)
                }

                factsSection

                if !receipt.notes.isEmpty {
                    notesSection
                }

                rawTextSection
            }
            .padding(20)
            .padding(.bottom, 28)
        }
        .background(backgroundGradient.ignoresSafeArea())
        .navigationTitle("Receipt")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(receipt.metadata.merchantName)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(receipt.metadata.source.displayName)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.78))
                }

                Spacer(minLength: 12)

                if let totalAmount = receipt.metadata.totalAmount {
                    Text(totalAmountText(totalAmount))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.white.opacity(0.12), in: Capsule())
                }
            }

            HStack(spacing: 12) {
                detailPill(
                    title: "Purchase Date",
                    value: receipt.metadata.purchaseDate.map(Self.dateFormatter.string) ?? "Not parsed"
                )

                detailPill(
                    title: "Captured",
                    value: Self.dateTimeFormatter.string(from: receipt.metadata.createdAt)
                )
            }
        }
        .padding(24)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var factsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Receipt Facts", subtitle: "Saved fields that came from OCR and receipt metadata.")

            VStack(spacing: 12) {
                factRow(title: "Merchant", value: receipt.metadata.merchantName)
                factRow(title: "Source", value: receipt.metadata.source.displayName)
                factRow(title: "Total", value: receipt.metadata.totalAmount.map(totalAmountText) ?? "Not parsed")
                factRow(title: "Currency", value: receipt.metadata.currencyCode ?? "Not parsed")
                factRow(title: "Purchase Date", value: receipt.metadata.purchaseDate.map(Self.dateFormatter.string) ?? "Not parsed")
                factRow(title: "Updated", value: Self.dateTimeFormatter.string(from: receipt.metadata.updatedAt))
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
    }

    private func receiptImageSection(fileName: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Saved Image", subtitle: "The original imported receipt image persisted on device.")

            StoredReceiptImageThumbnail(
                fileName: fileName,
                width: UIScreen.main.bounds.width - 40,
                height: 280
            )
            .frame(maxWidth: .infinity, alignment: .center)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Notes", subtitle: "Any saved annotation for this receipt.")

            Text(receipt.notes)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
    }

    private var rawTextSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Recognized Text", subtitle: "Full raw OCR output saved with this receipt.")

            if receipt.rawText.isEmpty {
                Text("No OCR text was saved for this receipt.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            } else {
                Text(receipt.rawText)
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            }
        }
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

    private func factRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 112, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func detailPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.62))

            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.black.opacity(0.14), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func totalAmountText(_ amount: Decimal) -> String {
        let formattedAmount = Self.currencyFormatter.string(from: amount as NSDecimalNumber)
            ?? Self.decimalFormatter.string(from: amount as NSDecimalNumber)
            ?? "\(amount)"

        guard let currencyCode = receipt.metadata.currencyCode else {
            return formattedAmount
        }

        if formattedAmount.contains(currencyCode) {
            return formattedAmount
        }

        return "\(currencyCode) \(formattedAmount)"
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

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()

    private static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

#Preview {
    NavigationStack {
        ReceiptDetailView(
            receipt: Receipt(
                metadata: ReceiptMetadata(
                    merchantName: "Cafe Esplanad",
                    purchaseDate: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 15)),
                    totalAmount: Decimal(string: "18.40"),
                    currencyCode: "EUR",
                    source: .photoLibrary
                ),
                notes: "Lunch receipt saved after OCR review.",
                rawText: """
                Cafe Esplanad
                Lunch Menu
                Total EUR 18.40
                15.05.2026
                """
            )
        )
    }
}
