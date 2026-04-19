//
//  BiometricAuthService.swift
//  LockBox
//
//  Created by Pekomon on 19.4.2026.
//

import Foundation
import LocalAuthentication

protocol BiometricAuthServicing {
    func availability() -> BiometricAuthAvailability
    func authenticate(reason: String) async throws
}

struct BiometricAuthAvailability: Equatable {
    let biometry: BiometricKind
    let isAvailable: Bool
    let unavailableReason: String?
}

enum BiometricKind: String, Equatable {
    case none
    case faceID
    case touchID
    case opticID
}

enum BiometricAuthError: LocalizedError, Equatable {
    case unavailable(BiometricKind, reason: String?)
    case authenticationFailed
    case userCancelled
    case userFallback
    case systemCancelled
    case notEnrolled
    case lockout
    case unknown

    var errorDescription: String? {
        switch self {
        case let .unavailable(kind, reason):
            switch kind {
            case .none:
                return reason ?? "Biometric authentication is not available on this device."
            case .faceID, .touchID, .opticID:
                return reason ?? "\(kind.displayName) is not available right now."
            }
        case .authenticationFailed:
            return "Biometric authentication failed."
        case .userCancelled:
            return "Biometric authentication was cancelled."
        case .userFallback:
            return "The user chose a fallback authentication method."
        case .systemCancelled:
            return "Biometric authentication was cancelled by the system."
        case .notEnrolled:
            return "No biometrics are enrolled on this device."
        case .lockout:
            return "Biometric authentication is locked due to too many failed attempts."
        case .unknown:
            return "Biometric authentication failed for an unknown reason."
        }
    }
}

final class BiometricAuthService: BiometricAuthServicing {
    func availability() -> BiometricAuthAvailability {
        let context = LAContext()
        var error: NSError?
        let isAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        return BiometricAuthAvailability(
            biometry: context.biometryType.lockBoxBiometricKind,
            isAvailable: isAvailable,
            unavailableReason: error?.localizedDescription
        )
    }

    func authenticate(reason: String) async throws {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw mapAvailabilityError(error, biometry: context.biometryType.lockBoxBiometricKind)
        }

        do {
            try await evaluateBiometrics(reason: reason, context: context)
        } catch let authError as BiometricAuthError {
            throw authError
        } catch {
            throw mapAuthenticationError(error)
        }
    }

    private func evaluateBiometrics(reason: String, context: LAContext) async throws {
        try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: self.mapAuthenticationError(error))
                }
            }
        }
    }

    private func mapAvailabilityError(_ error: Error?, biometry: BiometricKind) -> BiometricAuthError {
        guard let laError = error as? LAError else {
            return .unavailable(biometry, reason: error?.localizedDescription)
        }

        switch laError.code {
        case .biometryNotEnrolled:
            return .notEnrolled
        case .biometryLockout:
            return .lockout
        default:
            return .unavailable(biometry, reason: laError.localizedDescription)
        }
    }

    private func mapAuthenticationError(_ error: Error?) -> BiometricAuthError {
        guard let laError = error as? LAError else {
            return .unknown
        }

        switch laError.code {
        case .authenticationFailed:
            return .authenticationFailed
        case .userCancel:
            return .userCancelled
        case .userFallback:
            return .userFallback
        case .systemCancel, .appCancel, .invalidContext:
            return .systemCancelled
        case .biometryNotEnrolled:
            return .notEnrolled
        case .biometryLockout:
            return .lockout
        default:
            return .unknown
        }
    }
}

private extension LABiometryType {
    var lockBoxBiometricKind: BiometricKind {
        switch self {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        case .opticID:
            return .opticID
        @unknown default:
            return .none
        }
    }
}

private extension BiometricKind {
    var displayName: String {
        switch self {
        case .none:
            return "Biometrics"
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        }
    }
}
