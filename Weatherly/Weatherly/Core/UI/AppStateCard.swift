//
//  AppStateCard.swift
//  Weatherly
//
//  Created by Pekomon on 10.4.2026.
//

import SwiftUI

struct AppStateCard<Accessory: View>: View {
    let title: String
    let message: String
    let systemImage: String
    let tint: Color
    @ViewBuilder let accessory: Accessory

    init(
        title: String,
        message: String,
        systemImage: String,
        tint: Color,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.tint = tint
        self.accessory = accessory()
    }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.16))
                    .frame(width: 72, height: 72)

                Image(systemName: systemImage)
                    .font(.system(size: 29, weight: .semibold))
                    .foregroundStyle(tint)
            }

            VStack(spacing: 10) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            accessory
        }
        .frame(maxWidth: 420)
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
        .background(.ultraThinMaterial)
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

extension AppStateCard where Accessory == EmptyView {
    init(
        title: String,
        message: String,
        systemImage: String,
        tint: Color
    ) {
        self.init(
            title: title,
            message: message,
            systemImage: systemImage,
            tint: tint
        ) {
            EmptyView()
        }
    }
}
