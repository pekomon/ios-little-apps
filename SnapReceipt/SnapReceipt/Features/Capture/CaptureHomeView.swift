//
//  CaptureHomeView.swift
//  SnapReceipt
//
//  Created by Pekomon on 7.5.2026.
//

import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct CaptureHomeView: View {
    @State private var viewModel = CaptureHomeViewModel()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isShowingSourceDialog = false
    @State private var isShowingCamera = false
    @State private var isShowingPhotoPicker = false
    @State private var isShowingFileImporter = false
    @State private var isShowingCameraUnavailableAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        heroCard
                        if let importedAsset = viewModel.importedAsset {
                            importedPreviewCard(importedAsset)
                        }
                        quickActions
                        processPreview
                    }
                    .padding(24)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle("SnapReceipt")
            .navigationBarTitleDisplayMode(.large)
        }
        .confirmationDialog("Choose receipt source", isPresented: $isShowingSourceDialog) {
            Button("Camera") {
                openCameraIfAvailable()
            }

            Button("Photo Library") {
                isShowingPhotoPicker = true
            }

            Button("Files") {
                isShowingFileImporter = true
            }
        } message: {
            Text("Start with a live capture or bring in an existing receipt image.")
        }
        .alert("Camera Unavailable", isPresented: $isShowingCameraUnavailableAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This simulator cannot capture a receipt photo. Use Photo Library or Files instead.")
        }
        .sheet(isPresented: $isShowingCamera) {
            CameraImagePicker { image in
                viewModel.updateImportedAsset(
                    image: image,
                    source: .camera,
                    fileName: "Live Capture"
                )
            }
        }
        .photosPicker(
            isPresented: $isShowingPhotoPicker,
            selection: $selectedPhotoItem,
            matching: .images
        )
        .fileImporter(
            isPresented: $isShowingFileImporter,
            allowedContentTypes: [.image]
        ) { result in
            Task {
                await viewModel.importFile(result)
            }
        }
        .task(id: selectedPhotoItem) {
            guard let selectedPhotoItem else {
                return
            }

            await viewModel.importPhotoLibraryItem(selectedPhotoItem)
            self.selectedPhotoItem = nil
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Capture receipts in one pass")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Scan, import, and review expense details locally before anything is saved.")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.84))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 16)

                Label("Local first", systemImage: "internaldrive.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.84))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.10), in: Capsule())
            }

            HStack(spacing: 14) {
                summaryPill(title: "Stage", value: "Capture")
                summaryPill(title: "Focus", value: "Import Flow")
            }

            Button {
                isShowingSourceDialog = true
            } label: {
                Label("Add Receipt", systemImage: "plus.viewfinder")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0.97, green: 0.62, blue: 0.22))
        }
        .padding(24)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func importedPreviewCard(_ asset: ImportedReceiptAsset) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                asset.previewImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 96, height: 128)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(.white.opacity(0.10), lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 10) {
                    Label("Imported Receipt", systemImage: asset.source.systemImage)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(asset.fileName)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    Text(asset.source.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let imageSizeDescription = asset.imageSizeDescription {
                        Text(imageSizeDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 12) {
                Button("Choose Another") {
                    isShowingSourceDialog = true
                }
                .buttonStyle(.bordered)

                Text("OCR comes next in task 6.")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Receipt inputs", subtitle: "This milestone supports camera capture plus importing an existing image.")

            HStack(spacing: 14) {
                sourceActionButton(
                    title: "Camera Scan",
                    detail: "Frame a physical receipt and bring the image straight into the app.",
                    systemImage: "camera",
                    action: openCameraIfAvailable
                )

                sourceActionButton(
                    title: "Photo Import",
                    detail: "Choose a saved receipt image from your photo library.",
                    systemImage: "photo.on.rectangle",
                    action: {
                        isShowingPhotoPicker = true
                    }
                )
            }

            sourceActionButton(
                title: "File Import",
                detail: "Load a receipt image from Files when it was shared or downloaded elsewhere.",
                systemImage: "folder.badge.plus",
                action: {
                    isShowingFileImporter = true
                }
            )
        }
    }

    private var processPreview: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "What happens next", subtitle: "Task 5 stops at image acquisition. OCR and parsing land after this.")

            VStack(spacing: 12) {
                processRow(step: "1", title: "Pick a receipt image", detail: "Use the camera, photo library, or Files to bring a receipt into the app.")
                processRow(step: "2", title: "Verify the preview", detail: "Make sure the full receipt is visible and legible before extraction starts.")
                processRow(step: "3", title: "Run OCR later", detail: "The next task will turn the imported image into raw text for field parsing.")
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
    }

    private func summaryPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.62))
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.black.opacity(0.14), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func sourceActionButton(
        title: String,
        detail: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color(red: 0.97, green: 0.62, blue: 0.22))

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func processRow(step: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(step)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(Color(red: 0.10, green: 0.18, blue: 0.28), in: Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title3.weight(.bold))
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func openCameraIfAvailable() {
        #if targetEnvironment(simulator)
        isShowingCameraUnavailableAlert = true
        #else
        isShowingCamera = true
        #endif
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.16, blue: 0.24),
                Color(red: 0.18, green: 0.27, blue: 0.36),
                Color(red: 0.96, green: 0.79, blue: 0.57)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    CaptureHomeView()
}
