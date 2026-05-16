//
//  ReceiptsOverviewView.swift
//  SnapReceipt
//
//  Created by Pekomon on 7.5.2026.
//

import SwiftUI

struct ReceiptsOverviewView: View {
    @State private var receiptsStore: ReceiptsStore
    @State private var receiptPendingDeletion: Receipt?
    @State private var isDeletingReceipt = false
    @State private var deletionErrorMessage: String?

    init(receiptsStore: ReceiptsStore) {
        _receiptsStore = State(initialValue: receiptsStore)
    }

    var body: some View {
        NavigationStack {
            Group {
                if receiptsStore.isLoading && receiptsStore.receipts.isEmpty {
                    ProgressView("Loading receipts...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = receiptsStore.errorMessage, receiptsStore.receipts.isEmpty {
                    ContentUnavailableView(
                        "Could Not Load Receipts",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if receiptsStore.receipts.isEmpty {
                    ContentUnavailableView(
                        "No Saved Receipts",
                        systemImage: "receipt",
                        description: Text("Import and save a receipt from the Capture tab to build your local expense history.")
                    )
                } else {
                    List {
                        Section("Saved Receipts") {
                            ForEach(receiptsStore.receipts) { receipt in
                                NavigationLink {
                                    ReceiptDetailView(receipt: receipt, receiptsStore: receiptsStore)
                                } label: {
                                    receiptRow(receipt)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        receiptPendingDeletion = receipt
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }

                        Section("Library Status") {
                            statusRow(
                                title: "Stored locally",
                                subtitle: "\(receiptsStore.receipts.count) receipt\(receiptsStore.receipts.count == 1 ? "" : "s") available on this device."
                            )
                        }
                    }
                    .animation(.snappy(duration: 0.22), value: receiptsStore.receipts)
                }
            }
            .navigationTitle("Receipts")
            .refreshable {
                await receiptsStore.loadReceipts()
            }
            .confirmationDialog(
                "Delete Receipt?",
                isPresented: deleteConfirmationIsPresented,
                presenting: receiptPendingDeletion
            ) { receipt in
                Button("Delete Receipt", role: .destructive) {
                    Task {
                        await deleteReceipt(receipt)
                    }
                }
                Button("Cancel", role: .cancel) {
                    receiptPendingDeletion = nil
                }
            } message: { receipt in
                Text("This removes \(receipt.metadata.merchantName) and any saved receipt image from local storage.")
            }
            .alert("Could Not Delete Receipt", isPresented: deletionErrorIsPresented) {
                Button("OK") {
                    deletionErrorMessage = nil
                }
            } message: {
                Text(deletionErrorMessage ?? "")
            }
        }
    }

    private var deleteConfirmationIsPresented: Binding<Bool> {
        Binding(
            get: { receiptPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    receiptPendingDeletion = nil
                }
            }
        )
    }

    private var deletionErrorIsPresented: Binding<Bool> {
        Binding(
            get: { deletionErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    deletionErrorMessage = nil
                }
            }
        )
    }

    private func receiptRow(_ receipt: Receipt) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                if let imageFileName = receipt.imageFileName {
                    StoredReceiptImageThumbnail(
                        fileName: imageFileName,
                        width: 64,
                        height: 86
                    )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(receipt.metadata.merchantName)
                        .font(.headline)

                    Text(receipt.metadata.source.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 12)

                if let totalAmount = receipt.metadata.totalAmount {
                    Text(Self.currencyFormatter.string(from: totalAmount as NSDecimalNumber) ?? "\(totalAmount)")
                        .font(.headline.weight(.semibold))
                }
            }

            HStack(spacing: 12) {
                if let purchaseDate = receipt.metadata.purchaseDate {
                    Label(Self.dateFormatter.string(from: purchaseDate), systemImage: "calendar")
                }

                if let currencyCode = receipt.metadata.currencyCode {
                    Label(currencyCode, systemImage: "banknote")
                }
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)

            if !receipt.rawText.isEmpty {
                Text(receipt.rawText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 4)
    }

    private func statusRow(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    @MainActor
    private func deleteReceipt(_ receipt: Receipt) async {
        guard !isDeletingReceipt else {
            return
        }

        isDeletingReceipt = true
        receiptPendingDeletion = nil

        do {
            try await receiptsStore.deleteReceipt(receipt)
        } catch {
            deletionErrorMessage = error.localizedDescription
        }

        isDeletingReceipt = false
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "EUR"
        return formatter
    }()
}

#Preview {
    ReceiptsOverviewView(
        receiptsStore: ReceiptsStore(
            repository: DefaultReceiptRepository(receiptStore: JSONFileReceiptStore()),
            imageStore: ReceiptImageStore()
        )
    )
}
