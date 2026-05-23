//
//  ReceiptLineItem.swift
//  SnapReceipt
//
//  Created by Pekomon on 7.5.2026.
//

import Foundation

struct ReceiptLineItem: Identifiable, Hashable, Codable, Sendable {
    nonisolated let id: UUID
    nonisolated let title: String
    nonisolated let quantity: Decimal?
    nonisolated let amount: Decimal?

    nonisolated init(
        id: UUID = UUID(),
        title: String,
        quantity: Decimal? = nil,
        amount: Decimal? = nil
    ) {
        self.id = id
        self.title = title
        self.quantity = quantity
        self.amount = amount
    }
}
