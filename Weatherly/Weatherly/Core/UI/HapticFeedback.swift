//
//  HapticFeedback.swift
//  Weatherly
//
//  Created by Codex on 12.4.2026.
//

import UIKit

enum HapticFeedback {
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
}
