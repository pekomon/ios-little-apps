//
//  AppLockManager.swift
//  LockBox
//
//  Created by Pekomon on 19.4.2026.
//

import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class AppLockManager {
    private let biometricAuthService: any BiometricAuthServicing

    private(set) var lockState: AppLockState = .locked
    private(set) var biometricAvailability: BiometricAuthAvailability
    private(set) var lastUnlockError: BiometricAuthError?

    init(biometricAuthService: any BiometricAuthServicing = BiometricAuthService()) {
        self.biometricAuthService = biometricAuthService
        self.biometricAvailability = biometricAuthService.availability()
    }

    var canAttemptUnlock: Bool {
        biometricAvailability.isAvailable && lockState != .unlocking
    }

    func refreshBiometricAvailability() {
        biometricAvailability = biometricAuthService.availability()
    }

    func lock() {
        lockState = .locked
        lastUnlockError = nil
        refreshBiometricAvailability()
    }

    func unlock() async {
        lastUnlockError = nil
        refreshBiometricAvailability()

        guard biometricAvailability.isAvailable else {
            lockState = .locked
            lastUnlockError = .unavailable(
                biometricAvailability.biometry,
                reason: biometricAvailability.unavailableReason
            )
            return
        }

        lockState = .unlocking

        do {
            try await biometricAuthService.authenticate(reason: "Unlock your LockBox vault.")
            lockState = .unlocked
        } catch let error as BiometricAuthError {
            lockState = .locked
            lastUnlockError = error
            refreshBiometricAvailability()
        } catch {
            lockState = .locked
            lastUnlockError = .unknown
            refreshBiometricAvailability()
        }
    }

    func handleScenePhaseChange(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .active:
            refreshBiometricAvailability()
        case .background:
            if lockState == .unlocked {
                lock()
            }
        case .inactive:
            break
        @unknown default:
            break
        }
    }
}

enum AppLockState: Equatable {
    case locked
    case unlocking
    case unlocked
}
