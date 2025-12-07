//
//  SettingsView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(RecipeViewModel.self) private var viewModel

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
        }
    }
}

#Preview {
    SettingsView()
        .environment(RecipeViewModel())
}
