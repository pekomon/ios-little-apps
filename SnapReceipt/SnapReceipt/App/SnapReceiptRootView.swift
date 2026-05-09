//
//  SnapReceiptRootView.swift
//  SnapReceipt
//
//  Created by Pekomon on 7.5.2026.
//

import SwiftUI

struct SnapReceiptRootView: View {
    @State private var receiptsStore: ReceiptsStore

    init(receiptsStore: ReceiptsStore? = nil) {
        let liveStore = receiptsStore ?? ReceiptsStore(
            repository: DefaultReceiptRepository(receiptStore: JSONFileReceiptStore())
        )
        _receiptsStore = State(initialValue: liveStore)
    }

    var body: some View {
        TabView {
            CaptureHomeView(receiptsStore: receiptsStore)
                .tabItem {
                    Label("Capture", systemImage: "camera.viewfinder")
                }

            ReceiptsOverviewView(receiptsStore: receiptsStore)
                .tabItem {
                    Label("Receipts", systemImage: "list.bullet.rectangle")
                }

            SettingsPlaceholderView()
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
        }
        .task {
            guard receiptsStore.receipts.isEmpty, !receiptsStore.isLoading else {
                return
            }

            await receiptsStore.loadReceipts()
        }
    }
}

#Preview {
    SnapReceiptRootView(
        receiptsStore: ReceiptsStore(
            repository: DefaultReceiptRepository(receiptStore: JSONFileReceiptStore())
        )
    )
}
