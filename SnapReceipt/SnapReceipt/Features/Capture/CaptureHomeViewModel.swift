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
    var importedAsset: ImportedReceiptAsset?

    func updateImportedAsset(image: UIImage, source: ReceiptImportSource, fileName: String) {
        importedAsset = ImportedReceiptAsset(
            previewImage: Image(uiImage: image),
            pixelSize: image.size,
            fileName: fileName,
            source: source
        )
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
            updateImportedAsset(image: image, source: .photoLibrary, fileName: fileName)
        } catch {
            importedAsset = nil
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

            updateImportedAsset(image: image, source: .files, fileName: fileURL.lastPathComponent)
        } catch {
            importedAsset = nil
        }
    }
}

struct ImportedReceiptAsset {
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
}
