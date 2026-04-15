//
//  LockBoxRootView.swift
//  LockBox
//
//  Created by Pekomon on 15.4.2026.
//

import SwiftUI

struct LockBoxRootView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.11, blue: 0.16),
                    Color(red: 0.12, green: 0.17, blue: 0.23),
                    Color(red: 0.78, green: 0.71, blue: 0.56)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                header
                heroCard
                actionCard
                Spacer(minLength: 0)
                footer
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 24)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 52, height: 52)
                    .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("LockBox")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Private by default")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            Text("A local-first vault for notes, credentials, and small secrets you want kept on your device.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.86))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Your vault is empty")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.11, green: 0.15, blue: 0.20))

            Text("This shell sets the foundation for secure unlock, local storage, and intentional vault flows without introducing them yet.")
                .font(.body)
                .foregroundStyle(Color.black.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                shellBadge(title: "Local-first", systemImage: "iphone")
                shellBadge(title: "Biometric-ready", systemImage: "faceid")
                shellBadge(title: "No cloud sync", systemImage: "wifi.slash")
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var actionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Planned first-run flow")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 10) {
                flowRow(index: "01", title: "Create vault", subtitle: "Set up a local encrypted storage space.")
                flowRow(index: "02", title: "Enable unlock", subtitle: "Connect Face ID or device passcode.")
                flowRow(index: "03", title: "Add entries", subtitle: "Store secrets with a calm, focused editor.")
            }

            Button(action: {}) {
                HStack {
                    Text("Vault setup coming next")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .foregroundStyle(Color(red: 0.11, green: 0.15, blue: 0.20))
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityHint("Placeholder action for the future vault setup flow.")
        }
        .padding(24)
        .background(.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }

    private var footer: some View {
        HStack {
            Label("Shell only", systemImage: "square.dashed")
            Spacer()
            Text("Security and data flows land in later phases")
        }
        .font(.footnote.weight(.medium))
        .foregroundStyle(.white.opacity(0.76))
    }

    private func shellBadge(title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color(red: 0.11, green: 0.15, blue: 0.20))
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.8), in: Capsule())
    }

    private func flowRow(index: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(index)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.9))
                .frame(width: 34, height: 34)
                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.74))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    LockBoxRootView()
}
