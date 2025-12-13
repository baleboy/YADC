//
//  SettingsView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(RecipeViewModel.self) private var viewModel
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Units") {
                    Picker("Unit System", selection: Binding(
                        get: { viewModel.settings.unitSystem },
                        set: { viewModel.updateUnitSystem($0) }
                    )) {
                        Text("Metric (grams)").tag(UnitSystem.metric)
                        Text("Imperial (ounces)").tag(UnitSystem.imperial)
                    }
                }

                Section {
                    HStack {
                        Text("Dough Residue")
                        Spacer()
                        Text(viewModel.settings.doughResiduePercentage.percentageFormatted)
                            .foregroundStyle(.secondary)
                    }

                    Slider(
                        value: Binding(
                            get: { viewModel.settings.doughResiduePercentage },
                            set: { viewModel.updateDoughResidue($0) }
                        ),
                        in: 0...10,
                        step: 0.5
                    )
                } header: {
                    Text("Dough Residue")
                } footer: {
                    Text("Extra dough to account for what sticks to the bowl and tools during the process.")
                }

                Section {
                    Button("Reset All Data", role: .destructive) {
                        showResetConfirmation = true
                    }
                } footer: {
                    Text("Resets all recipe data and settings to their default values.")
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Reset All Data?", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    viewModel.resetToDefaults()
                }
            } message: {
                Text("This will reset your recipe and settings to their default values. This action cannot be undone.")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(RecipeViewModel())
}
