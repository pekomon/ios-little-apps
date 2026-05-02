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
    private let hapticFeedbackService: any HapticFeedbackServicing

    private(set) var lockState: AppLockState = .locked
    private(set) var biometricAvailability: BiometricAuthAvailability
    private(set) var lastUnlockError: BiometricAuthError?

    convenience init() {
        self.init(
            biometricAuthService: BiometricAuthService(),
            hapticFeedbackService: HapticFeedbackService()
        )
    }

    init(
        biometricAuthService: any BiometricAuthServicing,
        hapticFeedbackService: any HapticFeedbackServicing
    ) {
        self.biometricAuthService = biometricAuthService
        self.hapticFeedbackService = hapticFeedbackService
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
            hapticFeedbackService.notify(.error)
            return
        }

        lockState = .unlocking

        do {
            try await biometricAuthService.authenticate(reason: "Unlock your LockBox vault.")
            lockState = .unlocked
            hapticFeedbackService.notify(.success)
        } catch let error as BiometricAuthError {
            lockState = .locked
            lastUnlockError = error
            refreshBiometricAvailability()
            hapticFeedbackService.notify(hapticNotification(for: error))
        } catch {
            lockState = .locked
            lastUnlockError = .unknown
            refreshBiometricAvailability()
            hapticFeedbackService.notify(.error)
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

    private func hapticNotification(for error: BiometricAuthError) -> HapticNotificationKind {
        switch error {
        case .userCancelled, .userFallback, .systemCancelled:
            return .warning
        case .unavailable, .authenticationFailed, .notEnrolled, .lockout, .unknown:
            return .error
        }
    }
}

enum AppLockState: Equatable {
    case locked
    case unlocking
    case unlocked
}
