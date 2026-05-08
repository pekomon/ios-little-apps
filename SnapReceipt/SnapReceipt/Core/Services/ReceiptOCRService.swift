//
//  ReceiptOCRService.swift
//  SnapReceipt
//
//  Created by Pekomon on 8.5.2026.
//

import Foundation
import UIKit
@preconcurrency import Vision

protocol ReceiptOCRServicing: Sendable {
    nonisolated func recognizeText(in image: UIImage) async throws -> ReceiptOCRResult
}

struct VisionReceiptOCRService: ReceiptOCRServicing, Sendable {
    nonisolated func recognizeText(in image: UIImage) async throws -> ReceiptOCRResult {
        let cgImage = try image.cgImageForOCR()
        let observations: [VNRecognizedTextObservation] = try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: ReceiptOCRError.visionRequestFailed(error))
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                continuation.resume(returning: observations)
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false
            request.minimumTextHeight = 0.015

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let handler = VNImageRequestHandler(
                        cgImage: cgImage,
                        orientation: image.cgImageOrientation,
                        options: [:]
                    )
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: ReceiptOCRError.imageProcessingFailed(error))
                }
            }
        }

        let lines = observations.compactMap { observation in
            observation.topCandidates(1).first?.string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        .filter { !$0.isEmpty }

        return ReceiptOCRResult(
            lines: lines,
            rawText: lines.joined(separator: "\n")
        )
    }
}

struct ReceiptOCRResult: Hashable, Sendable {
    let lines: [String]
    let rawText: String
}

enum ReceiptOCRError: LocalizedError, Sendable {
    case unsupportedImage
    case imageProcessingFailed(Error)
    case visionRequestFailed(Error)

    var errorDescription: String? {
        switch self {
        case .unsupportedImage:
            "The selected image could not be prepared for text recognition."
        case .imageProcessingFailed:
            "SnapReceipt could not prepare the receipt image for OCR."
        case .visionRequestFailed:
            "SnapReceipt could not recognize text from the receipt image."
        }
    }
}

private extension UIImage {
    nonisolated func cgImageForOCR() throws -> CGImage {
        if let cgImage {
            return cgImage
        }

        let renderer = UIGraphicsImageRenderer(size: size)
        let renderedImage = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }

        guard let cgImage = renderedImage.cgImage else {
            throw ReceiptOCRError.unsupportedImage
        }

        return cgImage
    }

    nonisolated var cgImageOrientation: CGImagePropertyOrientation {
        switch imageOrientation {
        case .up:
            .up
        case .upMirrored:
            .upMirrored
        case .down:
            .down
        case .downMirrored:
            .downMirrored
        case .left:
            .left
        case .leftMirrored:
            .leftMirrored
        case .right:
            .right
        case .rightMirrored:
            .rightMirrored
        @unknown default:
            .up
        }
    }
}
