//
//  SettingsView.swift
//  Weatherly
//
//  Created by Pekomon on 15.3.2026.
//

import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase

    let viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                Form {
                    unitsSection
                    appearanceSection
                    locationSection
                    aboutSection
                }
                .formStyle(.grouped)
                .listSectionSpacing(18)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.refreshLocationAuthorizationStatus()
            }
            .onChange(of: scenePhase) { _, newPhase in
                guard newPhase == .active else {
                    return
                }

                viewModel.refreshLocationAuthorizationStatus()
            }
        }
    }

    private var unitsSection: some View {
        Section {
            SettingsPickerRow(
                title: "Temperature Unit",
                description: "Used for current conditions, feels-like temperature, and forecast values."
            ) {
                Picker(
                    "Temperature Unit",
                    selection: Binding(
                        get: { viewModel.temperatureUnit },
                        set: { viewModel.selectTemperatureUnit($0) }
                    )
                ) {
                    ForEach(TemperatureUnit.allCases, id: \.self) { unit in
                        Text(unit.settingsLabel)
                            .tag(unit)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            SettingsPickerRow(
                title: "Wind Speed Unit",
                description: "Used anywhere wind conditions are shown."
            ) {
                Picker(
                    "Wind Speed Unit",
                    selection: Binding(
                        get: { viewModel.windSpeedUnit },
                        set: { viewModel.selectWindSpeedUnit($0) }
                    )
                ) {
                    ForEach(WindSpeedUnit.allCases, id: \.self) { unit in
                        Text(unit.settingsLabel)
                            .tag(unit)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
        } header: {
            Label("Units", systemImage: "thermometer.medium")
        } footer: {
            Text("These preferences apply across Home, search results, and forecast views.")
        }
    }

    private var appearanceSection: some View {
        Section {
            SettingsPickerRow(
                title: "App Appearance",
                description: "Choose whether Weatherly follows the system style or keeps a consistent light or dark look."
            ) {
                Picker(
                    "App Appearance",
                    selection: Binding(
                        get: { viewModel.appearancePreference },
                        set: { viewModel.selectAppearancePreference($0) }
                    )
                ) {
                    ForEach(AppAppearancePreference.allCases, id: \.self) { preference in
                        Text(preference.settingsLabel)
                            .tag(preference)
                        }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
        } header: {
            Label("Appearance", systemImage: "paintbrush.pointed")
        } footer: {
            Text("System matches your device setting automatically.")
        }
    }

    private var aboutSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.95), Color.cyan.opacity(0.85)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)

                        Image(systemName: "cloud.sun.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .accessibilityHidden(true)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(viewModel.appName)
                            .font(.headline)

                        Text("A calm forecast companion")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(viewModel.appName)
                .accessibilityValue("A calm forecast companion")

                Text(viewModel.appDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 6)

            if let versionDescription = viewModel.versionDescription {
                LabeledContent("Version", value: versionDescription)
            }
        } header: {
            Label("About", systemImage: "info.circle")
        } footer: {
            Text("Designed for quick local weather checks and easy access to saved places.")
        }
    }

    private var locationSection: some View {
        Section {
            LabeledContent("Current Access", value: viewModel.locationAuthorizationStatusText)

            Text(viewModel.locationAuthorizationDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.vertical, 2)

            if viewModel.canOpenSystemLocationSettings {
                Button {
                    openAppSettings()
                } label: {
                    Label("Open App Settings", systemImage: "arrow.up.forward.app")
                }
            }
        } header: {
            Label("Location", systemImage: "location.circle")
        } footer: {
            Text("Location is only used to show weather for your current position.")
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.12),
                Color.cyan.opacity(0.06),
                Color(.systemGroupedBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        openURL(settingsURL)
    }
}

private struct SettingsPickerRow<Content: View>: View {
    let title: String
    let description: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))

                Text(description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            content
        }
        .padding(.vertical, 6)
    }
}

private extension TemperatureUnit {
    var settingsLabel: String {
        switch self {
        case .celsius:
            "Celsius"
        case .fahrenheit:
            "Fahrenheit"
        }
    }
}

private extension WindSpeedUnit {
    var settingsLabel: String {
        switch self {
        case .metersPerSecond:
            "m/s"
        case .kilometersPerHour:
            "km/h"
        }
    }
}

private extension AppAppearancePreference {
    var settingsLabel: String {
        switch self {
        case .system:
            "System"
        case .light:
            "Light"
        case .dark:
            "Dark"
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel())
}
