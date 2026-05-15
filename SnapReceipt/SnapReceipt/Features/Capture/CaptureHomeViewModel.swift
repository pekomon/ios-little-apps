//
//  CaptureHomeViewModel.swift
//  SnapReceipt
//
//  Created by Pekomon on 8.5.2026.
//

import Observation
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
import UIKit

@MainActor
@Observable
final class CaptureHomeViewModel {
    private let receiptsStore: ReceiptsStore
    private let ocrService: any ReceiptOCRServicing
    private let parsingService: any ReceiptParsingServicing

    var importedAsset: ImportedReceiptAsset?
    var ocrResult: ReceiptOCRResult?
    var parsedDetails: ParsedReceiptDetails?
    var isRecognizingText = false
    var isSavingReceipt = false
    var ocrErrorMessage: String?
    var saveErrorMessage: String?
    var saveSuccessMessage: String?

    init(
        receiptsStore: ReceiptsStore,
        ocrService: (any ReceiptOCRServicing)? = nil,
        parsingService: (any ReceiptParsingServicing)? = nil
    ) {
        self.receiptsStore = receiptsStore
        self.ocrService = ocrService ?? VisionReceiptOCRService()
        self.parsingService = parsingService ?? ReceiptParsingService()
    }

    func updateImportedAsset(image: UIImage, source: ReceiptImportSource, fileName: String) async {
        importedAsset = ImportedReceiptAsset(
            uiImage: image,
            previewImage: Image(uiImage: image),
            pixelSize: image.size,
            fileName: fileName,
            source: source
        )
        await recognizeText(in: image)
    }

    func importPhotoLibraryItem(_ item: PhotosPickerItem) async {
        do {
            guard
                let data = try await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data)
            else {
                return
            }

            let fileName = item.supportedContentTypes.first?.preferredFilenameExtension.map { "Photo.\($0)" } ?? "Photo Import"
            await updateImportedAsset(image: image, source: .photoLibrary, fileName: fileName)
        } catch {
            importedAsset = nil
            ocrResult = nil
            parsedDetails = nil
            ocrErrorMessage = nil
        }
    }

    func importFile(_ result: Result<URL, Error>) async {
        do {
            let fileURL = try result.get()
            let didStartAccessing = fileURL.startAccessingSecurityScopedResource()
            defer {
                if didStartAccessing {
                    fileURL.stopAccessingSecurityScopedResource()
                }
            }

            let data = try Data(contentsOf: fileURL)
            guard let image = UIImage(data: data) else {
                importedAsset = nil
                return
            }

            await updateImportedAsset(image: image, source: .files, fileName: fileURL.lastPathComponent)
        } catch {
            importedAsset = nil
            ocrResult = nil
            parsedDetails = nil
            ocrErrorMessage = nil
        }
    }

    private func recognizeText(in image: UIImage) async {
        isRecognizingText = true
        ocrErrorMessage = nil
        saveErrorMessage = nil
        saveSuccessMessage = nil

        do {
            let result = try await ocrService.recognizeText(in: image)
            ocrResult = result
            parsedDetails = parsingService.parseReceiptDetails(from: result)
        } catch {
            ocrResult = nil
            parsedDetails = nil
            ocrErrorMessage = error.localizedDescription
        }

        isRecognizingText = false
    }

    func saveImportedReceipt() async {
        guard let currentImportedAsset = importedAsset else {
            return
        }

        isSavingReceipt = true
        saveErrorMessage = nil
        saveSuccessMessage = nil

        let now = Date()
        let merchantName = resolvedMerchantName(from: currentImportedAsset)
        let source = currentImportedAsset.source.receiptSource
        let metadata = ReceiptMetadata(
            merchantName: merchantName,
            purchaseDate: parsedDetails?.purchaseDate,
            totalAmount: parsedDetails?.totalAmount,
            currencyCode: parsedDetails?.currencyCode,
            source: source,
            createdAt: now,
            updatedAt: now
        )
        let receipt = Receipt(
            metadata: metadata,
            notes: "",
            rawText: ocrResult?.rawText ?? ""
        )
        let imageData = currentImportedAsset.uiImage.jpegData(compressionQuality: 0.85)
            ?? currentImportedAsset.uiImage.pngData()

        do {
            try await receiptsStore.saveReceipt(receipt, imageData: imageData)
            importedAsset = nil
            ocrResult = nil
            parsedDetails = nil
            ocrErrorMessage = nil
            saveSuccessMessage = "Saved \(merchantName) to Receipts."
        } catch {
            saveErrorMessage = error.localizedDescription
        }

        isSavingReceipt = false
    }

    private func resolvedMerchantName(from importedAsset: ImportedReceiptAsset) -> String {
        if let merchantName = parsedDetails?.merchantName?.trimmingCharacters(in: .whitespacesAndNewlines),
           !merchantName.isEmpty {
            return merchantName
        }

        let baseName = importedAsset.fileName
            .replacingOccurrences(of: ".jpeg", with: "", options: [.caseInsensitive])
            .replacingOccurrences(of: ".jpg", with: "", options: [.caseInsensitive])
            .replacingOccurrences(of: ".png", with: "", options: [.caseInsensitive])
            .replacingOccurrences(of: ".heic", with: "", options: [.caseInsensitive])
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return baseName.isEmpty ? "Untitled Receipt" : baseName
    }
}

struct ImportedReceiptAsset {
    let uiImage: UIImage
    let previewImage: Image
    let pixelSize: CGSize
    let fileName: String
    let source: ReceiptImportSource

    var imageSizeDescription: String? {
        let width = Int(pixelSize.width.rounded())
        let height = Int(pixelSize.height.rounded())
        guard width > 0, height > 0 else {
            return nil
        }

        return "\(width) × \(height) px"
    }
}

enum ReceiptImportSource: String {
    case camera
    case photoLibrary
    case files

    var description: String {
        switch self {
        case .camera:
            "Captured live with the device camera."
        case .photoLibrary:
            "Imported from the user's photo library."
        case .files:
            "Imported from Files."
        }
    }

    var systemImage: String {
        switch self {
        case .camera:
            "camera.fill"
        case .photoLibrary:
            "photo.on.rectangle.angled"
        case .files:
            "folder.fill"
        }
    }

    var receiptSource: ReceiptSource {
        switch self {
        case .camera:
            .camera
        case .photoLibrary:
            .photoLibrary
        case .files:
            .fileImport
        }
    }
}
