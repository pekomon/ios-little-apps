//
//  SnapReceiptRootView.swift
//  SnapReceipt
//
//  Created by Pekomon on 7.5.2026.
//

import SwiftUI

struct SnapReceiptRootView: View {
    var body: some View {
        TabView {
            CaptureHomeView()
                .tabItem {
                    Label("Capture", systemImage: "camera.viewfinder")
                }

            ReceiptsOverviewView()
                .tabItem {
                    Label("Receipts", systemImage: "list.bullet.rectangle")
                }

            SettingsPlaceholderView()
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
        }
    }
}

#Preview {
    SnapReceiptRootView()
}
