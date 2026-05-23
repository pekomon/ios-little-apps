//
//  ReceiptPersistenceTests.swift
//  SnapReceiptTests
//
//  Created by Codex on 23.5.2026.
//

import Foundation
import Testing
@testable import SnapReceipt

struct ReceiptPersistenceTests {

    @Test
    func jsonReceiptStoreRoundTripsSavedReceipts() throws {
        let harness = try PersistenceHarness()
        let store = JSONFileReceiptStore(persistenceLocation: harness.location)
        let receipt = Self.makeReceipt()

        try store.saveReceipts([receipt])
        let loadedReceipts = try store.loadReceipts()

        #expect(loadedReceipts.count == 1)
        #expect(loadedReceipts[0].id == receipt.id)
        #expect(loadedReceipts[0].metadata.merchantName == receipt.metadata.merchantName)
        #expect(loadedReceipts[0].metadata.totalAmount == receipt.metadata.totalAmount)
        #expect(loadedReceipts[0].metadata.currencyCode == receipt.metadata.currencyCode)
        #expect(loadedReceipts[0].notes == receipt.notes)
        #expect(loadedReceipts[0].rawText == receipt.rawText)
    }

    @Test
    func imageStoreSavesAndDeletesReceiptImages() throws {
        let harness = try PersistenceHarness()
        let store = ReceiptImageStore(persistenceLocation: harness.location)
        let receiptID = UUID(uuidString: "11111111-2222-3333-4444-555555555555") ?? UUID()
        let imageData = Data([0xFF, 0xD8, 0xFF, 0xD9])

        let fileName = try store.saveImageData(imageData, for: receiptID)
        let imageURL = store.imageURL(for: fileName)

        #expect(FileManager.default.fileExists(atPath: imageURL.path))
        #expect(try Data(contentsOf: imageURL) == imageData)

        try store.deleteImage(named: fileName)

        #expect(!FileManager.default.fileExists(atPath: imageURL.path))
    }

    @Test
    func jsonReceiptStoreThrowsOnInvalidReceiptData() throws {
        let harness = try PersistenceHarness()
        let invalidJSON = Data("{\"not\":\"an array\"}".utf8)

        try FileManager.default.createDirectory(
            at: harness.location.directoryURL,
            withIntermediateDirectories: true
        )
        try invalidJSON.write(to: harness.location.receiptsFileURL, options: .atomic)

        let store = JSONFileReceiptStore(persistenceLocation: harness.location)

        #expect(throws: ReceiptPersistenceError.invalidReceiptData) {
            try store.loadReceipts()
        }
    }

    private static func makeReceipt() -> Receipt {
        Receipt(
            metadata: ReceiptMetadata(
                id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE") ?? UUID(),
                merchantName: "Cafe Esplanad",
                purchaseDate: Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 5, day: 15)),
                totalAmount: Decimal(string: "18.40"),
                currencyCode: "EUR",
                source: .photoLibrary,
                createdAt: Date(timeIntervalSince1970: 1_747_312_000),
                updatedAt: Date(timeIntervalSince1970: 1_747_312_300)
            ),
            notes: "Lunch receipt",
            rawText: "Cafe Esplanad\nTotal EUR 18.40"
        )
    }
}

private final class PersistenceHarness {
    let rootURL: URL
    let location: ReceiptPersistenceLocation

    init() throws {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("SnapReceiptTests-\(UUID().uuidString)", isDirectory: true)
        self.rootURL = rootURL
        self.location = ReceiptPersistenceLocation(baseDirectoryURL: rootURL, appDirectoryName: "Fixture")
        try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
    }

    deinit {
        try? FileManager.default.removeItem(at: rootURL)
    }
}
