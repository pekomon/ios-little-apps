//
//  CaptureHomeView.swift
//  SnapReceipt
//
//  Created by Pekomon on 7.5.2026.
//

import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct CaptureHomeView: View {
    @State private var viewModel: CaptureHomeViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isShowingSourceDialog = false
    @State private var isShowingCamera = false
    @State private var isShowingPhotoPicker = false
    @State private var isShowingFileImporter = false
    @State private var isShowingCameraUnavailableAlert = false
    @State private var reviewSession: ReceiptReviewSession?

    init(receiptsStore: ReceiptsStore) {
        _viewModel = State(initialValue: CaptureHomeViewModel(receiptsStore: receiptsStore))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        heroCard
                        if let saveSuccessMessage = viewModel.saveSuccessMessage {
                            successBanner(message: saveSuccessMessage)
                        }
                        if let importedAsset = viewModel.importedAsset {
                            importedPreviewCard(importedAsset)
                        }
                        quickActions
                        processPreview
                    }
                    .padding(24)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle("SnapReceipt")
            .navigationBarTitleDisplayMode(.large)
        }
        .confirmationDialog("Choose receipt source", isPresented: $isShowingSourceDialog) {
            Button("Camera") {
                openCameraIfAvailable()
            }

            Button("Photo Library") {
                isShowingPhotoPicker = true
            }

            Button("Files") {
                isShowingFileImporter = true
            }
        } message: {
            Text("Start with a live capture or bring in an existing receipt image.")
        }
        .alert("Camera Unavailable", isPresented: $isShowingCameraUnavailableAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This simulator cannot capture a receipt photo. Use Photo Library or Files instead.")
        }
        .sheet(isPresented: $isShowingCamera) {
            CameraImagePicker { image in
                Task {
                    await viewModel.updateImportedAsset(
                        image: image,
                        source: .camera,
                        fileName: "Live Capture"
                    )
                }
            }
        }
        .sheet(item: $reviewSession, onDismiss: {
            reviewSession = nil
        }) { session in
                ReceiptReviewView(
                    asset: session.asset,
                    sourceDescription: session.asset.source.description,
                    initialDraft: session.draft
                ) { updatedDraft in
                    try await viewModel.saveReviewedReceipt(updatedDraft, asset: session.asset)
                    reviewSession = nil
                }
        }
        .photosPicker(
            isPresented: $isShowingPhotoPicker,
            selection: $selectedPhotoItem,
            matching: .images
        )
        .fileImporter(
            isPresented: $isShowingFileImporter,
            allowedContentTypes: [.image]
        ) { result in
            Task {
                await viewModel.importFile(result)
            }
        }
        .task(id: selectedPhotoItem) {
            guard let selectedPhotoItem else {
                return
            }

            await viewModel.importPhotoLibraryItem(selectedPhotoItem)
            self.selectedPhotoItem = nil
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Capture receipts in one pass")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Scan, import, and review expense details locally before anything is saved.")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.84))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 16)

                Label("Local first", systemImage: "internaldrive.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.84))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.10), in: Capsule())
            }

            HStack(spacing: 14) {
                summaryPill(title: "Stage", value: viewModel.importedAsset == nil ? "Capture" : "Review")
                summaryPill(title: "OCR", value: viewModel.isRecognizingText ? "Running" : (viewModel.ocrResult == nil ? "Waiting" : "Ready"))
                summaryPill(title: "Ready", value: viewModel.importedAsset == nil ? "No" : "Yes")
            }

            Button {
                isShowingSourceDialog = true
            } label: {
                Label("Add Receipt", systemImage: "plus.viewfinder")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0.97, green: 0.62, blue: 0.22))
            .accessibilityHint("Choose whether to import a receipt from the camera, photo library, or Files.")
        }
        .padding(24)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    private func importedPreviewCard(_ asset: ImportedReceiptAsset) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                Image(uiImage: asset.uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 96, height: 128)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(.white.opacity(0.10), lineWidth: 1)
                    }
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 10) {
                    Label("Imported Receipt", systemImage: asset.source.systemImage)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(asset.fileName)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    Text(asset.source.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let imageSizeDescription = asset.imageSizeDescription {
                        Text(imageSizeDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    statusBadgeRow(for: asset)
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 12) {
                Button("Choose Another") {
                    isShowingSourceDialog = true
                }
                .buttonStyle(.bordered)
                .accessibilityHint("Replace this imported receipt with a different image.")

                Button {
                    if let importedAsset = viewModel.importedAsset,
                       let draft = viewModel.makeReviewDraft() {
                        reviewSession = ReceiptReviewSession(asset: importedAsset, draft: draft)
                    }
                } label: {
                    Text("Review & Save")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isRecognizingText || viewModel.isSavingReceipt)
                .accessibilityHint("Open the receipt review form before saving locally.")

                if viewModel.isSavingReceipt {
                    ProgressView()
                        .tint(.secondary)
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel("Saving receipt")
                } else {
                    Text("OCR runs immediately. Nothing is persisted until you save.")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }

            if let saveErrorMessage = viewModel.saveErrorMessage {
                Label(saveErrorMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(.subheadline)
                    .foregroundStyle(.orange)
            }

            reviewReadinessStrip
            parsedDetailsSection
            ocrStatusSection
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityLabel(importedReceiptAccessibilityLabel(for: asset))
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Receipt inputs", subtitle: "This milestone supports camera capture plus importing an existing image.")

            HStack(spacing: 14) {
                sourceActionButton(
                    title: "Camera Scan",
                    detail: "Frame a physical receipt and bring the image straight into the app.",
                    systemImage: "camera",
                    action: openCameraIfAvailable
                )

                sourceActionButton(
                    title: "Photo Import",
                    detail: "Choose a saved receipt image from your photo library.",
                    systemImage: "photo.on.rectangle",
                    action: {
                        isShowingPhotoPicker = true
                    }
                )
            }

            sourceActionButton(
                title: "File Import",
                detail: "Load a receipt image from Files when it was shared or downloaded elsewhere.",
                systemImage: "folder.badge.plus",
                action: {
                    isShowingFileImporter = true
                }
            )
        }
    }

    private var processPreview: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Processing Flow", subtitle: "A compact pipeline from image import to structured receipt record.")

            VStack(spacing: 12) {
                processRow(step: "1", title: "Pick a receipt image", detail: "Use the camera, photo library, or Files to bring a receipt into the app.")
                processRow(step: "2", title: "Extract raw text", detail: "Vision OCR reads the receipt image and returns line-by-line text.")
                processRow(step: "3", title: "Review and save", detail: "Check merchant, amount, currency, date, and notes before the receipt is persisted.")
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
    }

    private func successBanner(message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color(red: 0.13, green: 0.58, blue: 0.37))

            Text(message)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    @ViewBuilder
    private var parsedDetailsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Parsed Suggestions")
                    .font(.headline)

                Spacer(minLength: 12)

                if viewModel.parsedDetails != nil {
                    Text("\(parsedFieldCount) of 4 fields")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.58), in: Capsule())
                }
            }

            if let parsedDetails = viewModel.parsedDetails {
                HStack(spacing: 10) {
                    metricChip(title: "Merchant", value: parsedDetails.merchantName == nil ? "Missing" : "Found")
                    metricChip(title: "Amount", value: parsedDetails.totalAmount == nil ? "Missing" : "Found")
                    metricChip(title: "Date", value: parsedDetails.purchaseDate == nil ? "Missing" : "Found")
                }

                VStack(spacing: 10) {
                    parsedDetailRow(title: "Merchant", value: parsedDetails.merchantName ?? "No match")
                    parsedDetailRow(title: "Date", value: parsedDetails.purchaseDate.map(Self.captureDateFormatter.string) ?? "No match")

                    if let totalAmount = parsedDetails.totalAmount {
                        let currencyPrefix = parsedDetails.currencyCode.map { "\($0) " } ?? ""
                        parsedDetailRow(title: "Total", value: "\(currencyPrefix)\(Self.amountFormatter.string(for: totalAmount) ?? "\(totalAmount)")")
                    } else {
                        parsedDetailRow(title: "Total", value: "No match")
                    }

                    parsedDetailRow(title: "Currency", value: parsedDetails.currencyCode ?? "No match")
                }
            } else {
                Text("OCR results will be parsed into structured suggestions here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var reviewReadinessStrip: some View {
        HStack(spacing: 10) {
            readinessCard(
                title: "Structured Fields",
                value: "\(parsedFieldCount)/4",
                accent: Color(red: 0.88, green: 0.46, blue: 0.28)
            )

            readinessCard(
                title: "OCR Lines",
                value: viewModel.ocrResult.map { "\($0.lines.count)" } ?? "0",
                accent: Color(red: 0.23, green: 0.44, blue: 0.70)
            )

            readinessCard(
                title: "Save State",
                value: viewModel.isRecognizingText ? "Busy" : "Ready",
                accent: Color(red: 0.18, green: 0.60, blue: 0.42)
            )
        }
    }

    @ViewBuilder
    private var ocrStatusSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recognized Text")
                .font(.headline)

            if viewModel.isRecognizingText {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Scanning receipt text...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Scanning receipt text")
            } else if let ocrErrorMessage = viewModel.ocrErrorMessage {
                Label(ocrErrorMessage, systemImage: "exclamationmark.triangle")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .accessibilityElement(children: .combine)
            } else if let ocrResult = viewModel.ocrResult, !ocrResult.rawText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(ocrResult.lines.count) lines found")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(ocrResult.rawText)
                        .font(.system(.footnote, design: .monospaced))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(.black.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Recognized text. \(ocrResult.lines.count) lines found. \(ocrResult.rawText)")
            } else {
                Text("Import a clear receipt image to see the raw OCR output here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func summaryPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.62))
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.black.opacity(0.14), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func sourceActionButton(
        title: String,
        detail: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color(red: 0.97, green: 0.62, blue: 0.22))
                    .accessibilityHidden(true)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityHint(detail)
    }

    private func readinessCard(title: String, value: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 999, style: .continuous)
                .fill(accent)
                .frame(width: 26, height: 5)

            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func metricChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func processRow(step: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(step)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(Color(red: 0.10, green: 0.18, blue: 0.28), in: Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }

    private func parsedDetailRow(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 82, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 2)
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title3.weight(.bold))
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func openCameraIfAvailable() {
        #if targetEnvironment(simulator)
        isShowingCameraUnavailableAlert = true
        #else
        isShowingCamera = true
        #endif
    }

    private var backgroundGradient: some View {
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

    private static let captureDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    private var parsedFieldCount: Int {
        guard let parsedDetails = viewModel.parsedDetails else {
            return 0
        }

        return [
            parsedDetails.merchantName?.isEmpty == false,
            parsedDetails.purchaseDate != nil,
            parsedDetails.totalAmount != nil,
            parsedDetails.currencyCode?.isEmpty == false
        ]
        .filter { $0 }
        .count
    }

    private func statusBadgeRow(for asset: ImportedReceiptAsset) -> some View {
        HStack(spacing: 8) {
            badgeLabel(text: asset.source == .camera ? "Live Capture" : "Imported")
            badgeLabel(text: viewModel.isRecognizingText ? "OCR Running" : "OCR Snapshot")

            if parsedFieldCount > 0 {
                badgeLabel(text: "\(parsedFieldCount) Fields")
            }
        }
    }

    private func badgeLabel(text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.white.opacity(0.58), in: Capsule())
    }

    private func importedReceiptAccessibilityLabel(for asset: ImportedReceiptAsset) -> String {
        var parts = [
            "Imported receipt",
            asset.fileName,
            asset.source.description
        ]

        if let size = asset.imageSizeDescription {
            parts.append(size)
        }

        if viewModel.isRecognizingText {
            parts.append("OCR is in progress")
        } else if let parsedDetails = viewModel.parsedDetails {
            if let merchantName = parsedDetails.merchantName, !merchantName.isEmpty {
                parts.append("Merchant \(merchantName)")
            }
            if let currencyCode = parsedDetails.currencyCode {
                parts.append("Currency \(currencyCode)")
            }
            if let totalAmount = parsedDetails.totalAmount {
                let total = Self.amountFormatter.string(for: totalAmount) ?? "\(totalAmount)"
                parts.append("Total \(total)")
            }
        }

        return parts.joined(separator: ". ")
    }
}

private struct ReceiptReviewSession: Identifiable {
    let id = UUID()
    let asset: ImportedReceiptAsset
    let draft: ReceiptReviewDraft
}

#Preview {
    CaptureHomeView(
        receiptsStore: ReceiptsStore(
            repository: DefaultReceiptRepository(receiptStore: JSONFileReceiptStore()),
            imageStore: ReceiptImageStore()
        )
    )
}
