//
//  HapticFeedbackService.swift
//  LockBox
//
//  Created by Pekomon on 30.4.2026.
//

import UIKit

protocol HapticFeedbackServicing {
    func notify(_ feedback: HapticNotificationKind)
    func impact(_ style: HapticImpactStyle)
}

enum HapticNotificationKind {
    case success
    case warning
    case error
}

enum HapticImpactStyle {
    case light
    case medium
}

struct HapticFeedbackService: HapticFeedbackServicing {
    func notify(_ feedback: HapticNotificationKind) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()

        switch feedback {
        case .success:
            generator.notificationOccurred(.success)
        case .warning:
            generator.notificationOccurred(.warning)
        case .error:
            generator.notificationOccurred(.error)
        }
    }

    func impact(_ style: HapticImpactStyle) {
        let generator = UIImpactFeedbackGenerator(style: style.uiKitStyle)
        generator.prepare()
        generator.impactOccurred()
    }
}

private extension HapticImpactStyle {
    var uiKitStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .light:
            return .light
        case .medium:
            return .medium
        }
    }
}
