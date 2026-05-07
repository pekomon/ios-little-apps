//
//  Receipt.swift
//  SnapReceipt
//
//  Created by Pekomon on 7.5.2026.
//

import Foundation

struct Receipt: Identifiable, Hashable, Codable, Sendable {
    let metadata: ReceiptMetadata
    let lineItems: [ReceiptLineItem]
    let notes: String
    let rawText: String

    var id: UUID {
        metadata.id
    }

    init(
        metadata: ReceiptMetadata,
        lineItems: [ReceiptLineItem] = [],
        notes: String = "",
        rawText: String = ""
    ) {
        self.metadata = metadata
        self.lineItems = lineItems
        self.notes = notes
        self.rawText = rawText
    }

    func updating(
        metadata: ReceiptMetadata? = nil,
        lineItems: [ReceiptLineItem]? = nil,
        notes: String? = nil,
        rawText: String? = nil
    ) -> Receipt {
        Receipt(
            metadata: metadata ?? self.metadata,
            lineItems: lineItems ?? self.lineItems,
            notes: notes ?? self.notes,
            rawText: rawText ?? self.rawText
        )
    }
}
