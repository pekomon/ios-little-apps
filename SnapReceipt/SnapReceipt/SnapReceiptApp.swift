//
//  SnapReceiptApp.swift
//  SnapReceipt
//
//  Created by Pekomon on 6.5.2026.
//

import SwiftUI

@main
struct SnapReceiptApp: App {
    init() {
        SnapReceiptDemoSeeder.seedIfNeeded(for: .current)
    }

    var body: some Scene {
        WindowGroup {
            SnapReceiptRootView()
        }
    }
}
