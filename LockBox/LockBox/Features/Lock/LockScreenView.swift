//
//  LockScreenView.swift
//  LockBox
//
//  Created by Pekomon on 19.4.2026.
//

import SwiftUI

struct LockScreenView: View {
    let appLockManager: AppLockManager

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                lockGlyph
                titleBlock
                statusCard
                unlockButton
            }
            .padding(24)
        }
    }

    private var lockGlyph: some View {
        Image(systemName: appLockManager.lockState == .unlocked ? "lock.open.fill" : "lock.fill")
            .font(.system(size: 34, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 78, height: 78)
            .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .accessibilityHidden(true)
    }

    private var titleBlock: some View {
        VStack(spacing: 10) {
            Text("Vault Locked")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Unlock with \(appLockManager.biometricAvailability.biometry.displayName) to continue into your local vault.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.78))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            statusRow(title: "Status", value: statusText)
            statusRow(title: "Biometrics", value: biometricText)

            if let errorText = errorText {
                Text(errorText)
                    .font(.footnote)
                    .foregroundStyle(Color(red: 1.0, green: 0.86, blue: 0.83))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .frame(maxWidth: 420)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var unlockButton: some View {
        Button {
            Task {
                await appLockManager.unlock()
            }
        } label: {
            HStack {
                if appLockManager.lockState == .unlocking {
                    ProgressView()
                        .tint(Color(red: 0.11, green: 0.15, blue: 0.20))
                } else {
                    Image(systemName: iconName)
                }

                Text(buttonTitle)
            }
            .font(.headline)
            .foregroundStyle(Color(red: 0.11, green: 0.15, blue: 0.20))
            .padding(.horizontal, 22)
            .padding(.vertical, 16)
            .frame(maxWidth: 420)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!appLockManager.canAttemptUnlock)
        .opacity(appLockManager.canAttemptUnlock ? 1 : 0.7)
        .accessibilityHint("Attempts biometric unlock for the vault.")
    }

    private var statusText: String {
        switch appLockManager.lockState {
        case .locked:
            return "Locked"
        case .unlocking:
            return "Authenticating"
        case .unlocked:
            return "Unlocked"
        }
    }

    private var biometricText: String {
        let availability = appLockManager.biometricAvailability
        let summary = availability.isAvailable ? "Available" : "Unavailable"
        return "\(availability.biometry.displayName) • \(summary)"
    }

    private var errorText: String? {
        appLockManager.lastUnlockError?.errorDescription
    }

    private var buttonTitle: String {
        switch appLockManager.lockState {
        case .locked:
            return "Unlock with \(appLockManager.biometricAvailability.biometry.displayName)"
        case .unlocking:
            return "Unlocking"
        case .unlocked:
            return "Unlocked"
        }
    }

    private var iconName: String {
        switch appLockManager.biometricAvailability.biometry {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .opticID:
            return "opticid"
        case .none:
            return "lock.shield"
        }
    }

    private func statusRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.black.opacity(0.6))

            Spacer()

            Text(value)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(red: 0.11, green: 0.15, blue: 0.20))
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    LockScreenView(appLockManager: AppLockManager())
}
