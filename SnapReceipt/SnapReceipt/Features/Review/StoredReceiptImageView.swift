//
//  StoredReceiptImageView.swift
//  SnapReceipt
//
//  Created by Pekomon on 15.5.2026.
//

import SwiftUI
import UIKit

struct StoredReceiptImageThumbnail: View {
    let fileName: String
    let width: CGFloat
    let height: CGFloat

    private let imageStore = ReceiptImageStore()

    var body: some View {
        if let uiImage = UIImage(contentsOfFile: imageStore.imageURL(for: fileName).path) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.primary.opacity(0.08), lineWidth: 1)
                }
                .accessibilityLabel("Receipt image")
        } else {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(width: width, height: height)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Receipt image unavailable")
        }
    }
}
