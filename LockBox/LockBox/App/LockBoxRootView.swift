//
//  LockBoxRootView.swift
//  LockBox
//
//  Created by Pekomon on 15.4.2026.
//

import SwiftUI

struct LockBoxRootView: View {
    @State private var appLockManager = AppLockManager()
    @State private var vaultListViewModel: VaultListViewModel

    init() {
        let repository = DefaultVaultRepository(
            metadataStore: JSONFileVaultEntryMetadataStore(),
            secureValueStore: KeychainSecureValueStore()
        )
        _vaultListViewModel = State(initialValue: VaultListViewModel(repository: repository))
    }

    var body: some View {
        ZStack {
            shellContent
                .blur(radius: appLockManager.lockState == .unlocked ? 0 : 18)
                .overlay {
                    if appLockManager.lockState != .unlocked {
                        Color.black.opacity(0.18)
                            .ignoresSafeArea()
                    }
                }
                .allowsHitTesting(appLockManager.lockState == .unlocked)

            if appLockManager.lockState != .unlocked {
                LockScreenView(appLockManager: appLockManager)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: appLockManager.lockState)
    }

    private var shellContent: some View {
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

            VStack(spacing: 0) {
                VaultListView(viewModel: vaultListViewModel)

                HStack {
                    Label(appLockManager.lockState == .unlocked ? "Unlocked" : "Locked", systemImage: "lock.shield")
                    Spacer()
                    Text("Local vault ready")
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.white.opacity(0.76))
            }
        }
    }
}

#Preview {
    LockBoxRootView()
}
