//
//  SnapReceiptRootView.swift
//  SnapReceipt
//
//  Created by Pekomon on 7.5.2026.
//

import SwiftUI

enum SnapReceiptRootTab: Hashable {
    case capture
    case receipts
    case settings
}

struct SnapReceiptRootView: View {
    @State private var receiptsStore: ReceiptsStore
    @State private var selectedTab: SnapReceiptRootTab
    private let launchConfiguration: SnapReceiptLaunchConfiguration

    init(
        receiptsStore: ReceiptsStore? = nil,
        launchConfiguration: SnapReceiptLaunchConfiguration = .current
    ) {
        self.launchConfiguration = launchConfiguration
        let liveStore = receiptsStore ?? ReceiptsStore(
            repository: DefaultReceiptRepository(receiptStore: JSONFileReceiptStore()),
            imageStore: ReceiptImageStore()
        )
        _receiptsStore = State(initialValue: liveStore)
        _selectedTab = State(initialValue: launchConfiguration.initialTab)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            CaptureHomeView(receiptsStore: receiptsStore, demoScenario: launchConfiguration.demoScenario)
                .tag(SnapReceiptRootTab.capture)
                .tabItem {
                    Label("Capture", systemImage: "camera.viewfinder")
                }

            ReceiptsOverviewView(receiptsStore: receiptsStore)
                .tag(SnapReceiptRootTab.receipts)
                .tabItem {
                    Label("Receipts", systemImage: "list.bullet.rectangle")
                }

            SettingsView()
                .tag(SnapReceiptRootTab.settings)
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
            repository: DefaultReceiptRepository(receiptStore: JSONFileReceiptStore()),
            imageStore: ReceiptImageStore()
        )
    )
}
