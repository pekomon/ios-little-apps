//
//  SnapReceiptDemoSupport.swift
//  SnapReceipt
//
//  Created by Codex on 19.5.2026.
//

import Foundation
import UIKit

enum SnapReceiptDemoScenario: String {
    case capture
    case review
    case receipts
    case settings
}

struct SnapReceiptLaunchConfiguration {
    let demoScenario: SnapReceiptDemoScenario?

    static var current: SnapReceiptLaunchConfiguration {
        let environment = ProcessInfo.processInfo.environment
        let demoScenario = environment["SNAPRECEIPT_DEMO_SCENARIO"].flatMap(SnapReceiptDemoScenario.init(rawValue:))
        return SnapReceiptLaunchConfiguration(demoScenario: demoScenario)
    }

    var initialTab: SnapReceiptRootTab {
        switch demoScenario {
        case .receipts:
            .receipts
        case .settings:
            .settings
        case .capture, .review, .none:
            .capture
        }
    }
}

enum SnapReceiptDemoSeeder {
    static func seedIfNeeded(for configuration: SnapReceiptLaunchConfiguration) {
        guard configuration.demoScenario != nil else {
            return
        }

        let location = ReceiptPersistenceLocation()
        let imageStore = ReceiptImageStore(persistenceLocation: location)
        let receiptStore = JSONFileReceiptStore(persistenceLocation: location)

        do {
            let demoReceipt = makeDemoReceipt()
            let imageData = makeDemoImage().jpegData(compressionQuality: 0.88)
            let imageFileName = try imageData.map { try imageStore.saveImageData($0, for: demoReceipt.id) }
            let persistedReceipt = demoReceipt.updating(imageFileName: imageFileName)
            try receiptStore.saveReceipts([persistedReceipt])
        } catch {
            assertionFailure("Failed to seed SnapReceipt demo data: \(error)")
        }
    }

    static func makeDemoImportedAsset() -> ImportedReceiptAsset {
        ImportedReceiptAsset(
            uiImage: makeDemoImage(),
            pixelSize: CGSize(width: 1400, height: 2200),
            fileName: "CafeEsplanad-May15.jpg",
            source: .photoLibrary
        )
    }

    static func makeDemoOCRResult() -> ReceiptOCRResult {
        let lines = [
            "Cafe Esplanad",
            "Lunch Menu",
            "Table 14",
            "Total EUR 18.40",
            "15.05.2026"
        ]

        return ReceiptOCRResult(
            lines: lines,
            rawText: lines.joined(separator: "\n")
        )
    }

    static func makeDemoParsedDetails() -> ParsedReceiptDetails {
        ParsedReceiptDetails(
            merchantName: "Cafe Esplanad",
            purchaseDate: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 15)),
            totalAmount: Decimal(string: "18.40"),
            currencyCode: "EUR"
        )
    }

    static func makeDemoDraft() -> ReceiptReviewDraft {
        ReceiptReviewDraft(
            merchantName: "Cafe Esplanad",
            purchaseDate: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 15)) ?? .now,
            includesPurchaseDate: true,
            totalAmountText: "18.40",
            currencyCode: "EUR",
            notes: "Lunch receipt saved after OCR review.",
            rawText: makeDemoOCRResult().rawText,
            source: .photoLibrary
        )
    }

    private static func makeDemoReceipt() -> Receipt {
        Receipt(
            metadata: ReceiptMetadata(
                id: UUID(uuidString: "A1B2C3D4-E5F6-47A8-91B2-1234567890AB") ?? UUID(),
                merchantName: "Cafe Esplanad",
                purchaseDate: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 15)),
                totalAmount: Decimal(string: "18.40"),
                currencyCode: "EUR",
                source: .photoLibrary,
                createdAt: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 15, hour: 12, minute: 42)) ?? .now,
                updatedAt: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 15, hour: 12, minute: 47)) ?? .now
            ),
            notes: "Lunch receipt saved after OCR review.",
            rawText: makeDemoOCRResult().rawText
        )
    }

    private static func makeDemoImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 900, height: 1400))

        return renderer.image { context in
            let cg = context.cgContext

            let colors = [UIColor(red: 0.99, green: 0.97, blue: 0.94, alpha: 1).cgColor,
                          UIColor(red: 0.96, green: 0.91, blue: 0.84, alpha: 1).cgColor] as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1])!
            cg.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 900, y: 1400), options: [])

            UIColor(red: 0.87, green: 0.40, blue: 0.29, alpha: 1).setFill()
            UIBezierPath(roundedRect: CGRect(x: 90, y: 90, width: 720, height: 1160), cornerRadius: 44).fill()

            UIColor.white.setFill()
            UIBezierPath(roundedRect: CGRect(x: 118, y: 118, width: 664, height: 1104), cornerRadius: 32).fill()

            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .left

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 52, weight: .bold),
                .foregroundColor: UIColor(red: 0.14, green: 0.20, blue: 0.29, alpha: 1),
                .paragraphStyle: paragraph
            ]

            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 34, weight: .medium),
                .foregroundColor: UIColor(red: 0.28, green: 0.34, blue: 0.42, alpha: 1),
                .paragraphStyle: paragraph
            ]

            NSString(string: "Cafe Esplanad").draw(in: CGRect(x: 170, y: 170, width: 500, height: 70), withAttributes: titleAttributes)
            NSString(string: "Lunch Menu").draw(in: CGRect(x: 170, y: 270, width: 500, height: 46), withAttributes: bodyAttributes)
            NSString(string: "Table 14").draw(in: CGRect(x: 170, y: 335, width: 500, height: 46), withAttributes: bodyAttributes)

            UIColor(red: 0.95, green: 0.61, blue: 0.39, alpha: 1).setFill()
            UIBezierPath(roundedRect: CGRect(x: 170, y: 520, width: 560, height: 150), cornerRadius: 30).fill()

            let totalAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 42, weight: .bold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraph
            ]

            NSString(string: "TOTAL  EUR 18.40").draw(in: CGRect(x: 210, y: 565, width: 420, height: 52), withAttributes: totalAttributes)
            NSString(string: "15.05.2026").draw(in: CGRect(x: 170, y: 760, width: 400, height: 46), withAttributes: bodyAttributes)

            UIColor(red: 0.86, green: 0.88, blue: 0.91, alpha: 1).setStroke()
            cg.setLineWidth(6)
            for index in 0..<6 {
                let y = 860 + CGFloat(index) * 70
                cg.move(to: CGPoint(x: 170, y: y))
                cg.addLine(to: CGPoint(x: 730, y: y))
                cg.strokePath()
            }
        }
    }
}
