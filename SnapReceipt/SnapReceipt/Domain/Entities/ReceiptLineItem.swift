//
//  ReceiptLineItem.swift
//  SnapReceipt
//
//  Created by Pekomon on 7.5.2026.
//

import Foundation

struct ReceiptLineItem: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    let title: String
    let quantity: Decimal?
    let amount: Decimal?

    init(
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
