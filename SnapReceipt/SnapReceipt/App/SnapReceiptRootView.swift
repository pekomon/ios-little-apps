//
//  SnapReceiptRootView.swift
//  SnapReceipt
//
//  Created by Pekomon on 6.5.2026.
//

import SwiftUI

struct SnapReceiptRootView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("SnapReceipt")
                    .font(.largeTitle.bold())

                Text("Project scaffold ready. Receipt capture, OCR, and review flows will land in the next tasks.")
                    .font(.body)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(24)
            .navigationTitle("SnapReceipt")
        }
    }
}

#Preview {
    SnapReceiptRootView()
}

