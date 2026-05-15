//
//  Receipt.swift
//  SnapReceipt
//
//  Created by Pekomon on 7.5.2026.
//

import Foundation

struct Receipt: Identifiable, Hashable, Codable, Sendable {
    let metadata: ReceiptMetadata
    let imageFileName: String?
    let lineItems: [ReceiptLineItem]
    let notes: String
    let rawText: String

    var id: UUID {
        metadata.id
    }

    init(
        metadata: ReceiptMetadata,
        imageFileName: String? = nil,
        lineItems: [ReceiptLineItem] = [],
        notes: String = "",
        rawText: String = ""
    ) {
        self.metadata = metadata
        self.imageFileName = imageFileName
        self.lineItems = lineItems
        self.notes = notes
        self.rawText = rawText
    }

    func updating(
        metadata: ReceiptMetadata? = nil,
        imageFileName: String? = nil,
        lineItems: [ReceiptLineItem]? = nil,
        notes: String? = nil,
        rawText: String? = nil
    ) -> Receipt {
        Receipt(
            metadata: metadata ?? self.metadata,
            imageFileName: imageFileName ?? self.imageFileName,
            lineItems: lineItems ?? self.lineItems,
            notes: notes ?? self.notes,
            rawText: rawText ?? self.rawText
        )
    }
}
