//
//  SettingsView.swift
//  Weatherly
//
//  Created by Pekomon on 15.3.2026.
//

import SwiftUI

struct SettingsView: View {
    let viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                Form {
                    unitsSection
                    appearanceSection
                    aboutSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var unitsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                Text("Temperature")
                    .font(.subheadline.weight(.semibold))

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
            .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 10) {
                Text("Wind Speed")
                    .font(.subheadline.weight(.semibold))

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
            .padding(.vertical, 4)
        } header: {
            Label("Units", systemImage: "thermometer.medium")
        } footer: {
            Text("Choose how weather values should be shown throughout the app.")
        }
    }

    private var appearanceSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                Text("App Appearance")
                    .font(.subheadline.weight(.semibold))

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
            .padding(.vertical, 4)
        } header: {
            Label("Appearance", systemImage: "circle.lefthalf.filled")
        } footer: {
            Text("Choose whether Weatherly follows the system appearance or always uses a light or dark look.")
        }
    }

    private var aboutSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                Text(viewModel.appName)
                    .font(.headline)

                Text(viewModel.appDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)

            if let versionDescription = viewModel.versionDescription {
                LabeledContent("Version", value: versionDescription)
            }
        } header: {
            Label("About", systemImage: "info.circle")
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
