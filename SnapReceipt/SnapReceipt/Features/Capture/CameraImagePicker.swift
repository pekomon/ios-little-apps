//
//  CameraImagePicker.swift
//  SnapReceipt
//
//  Created by Pekomon on 8.5.2026.
//

import SwiftUI
import UIKit

struct CameraImagePicker: UIViewControllerRepresentable {
    let onImagePicked: @MainActor (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked, dismiss: dismiss)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.delegate = context.coordinator
        controller.sourceType = .camera
        controller.allowsEditing = false
        return controller
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let onImagePicked: @MainActor (UIImage) -> Void
        private let dismiss: DismissAction

        init(onImagePicked: @escaping @MainActor (UIImage) -> Void, dismiss: DismissAction) {
            self.onImagePicked = onImagePicked
            self.dismiss = dismiss
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                Task { @MainActor in
                    onImagePicked(image)
                    dismiss()
                }
            } else {
                dismiss()
            }
        }
    }
}
