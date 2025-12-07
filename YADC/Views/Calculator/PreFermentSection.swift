//
//  PreFermentSection.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import SwiftUI

struct PreFermentSection: View {
    @Environment(RecipeViewModel.self) private var viewModel

    var body: some View {
        Section {
            Toggle("Use Pre-ferment", isOn: Binding(
                get: { viewModel.recipe.preFerment.isEnabled },
                set: { viewModel.togglePreFerment($0) }
            ))

            if viewModel.recipe.preFerment.isEnabled {
                Picker("Type", selection: Binding(
                    get: { viewModel.recipe.preFerment.type },
                    set: { viewModel.updatePreFermentType($0) }
                )) {
                    ForEach(PreFermentType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }

                HStack {
                    Text("Flour")
                    Spacer()
                    TextField("", value: Binding(
                        get: { viewModel.displayWeight(viewModel.recipe.preFerment.flourWeight) },
                        set: { viewModel.updatePreFermentFlour(viewModel.weightFromInput($0)) }
                    ), format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                    Text(viewModel.weightUnit)
                        .foregroundStyle(.secondary)
                }

                if viewModel.recipe.preFerment.type == .custom {
                    HStack {
                        Text("Hydration")
                        Spacer()
                        TextField("", value: Binding(
                            get: { viewModel.recipe.preFerment.hydration },
                            set: { viewModel.updatePreFermentHydration($0) }
                        ), format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                        Text("%")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    HStack {
                        Text("Hydration")
                        Spacer()
                        Text(viewModel.recipe.preFerment.hydration.percentageFormatted)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack {
                    Text("Water")
                    Spacer()
                    Text("\(viewModel.displayWeight(viewModel.recipe.preFerment.waterWeight).weightFormatted) \(viewModel.weightUnit)")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Yeast")
                    Spacer()
                    TextField("", value: Binding(
                        get: { viewModel.recipe.preFerment.yeastPercentage },
                        set: { viewModel.updatePreFermentYeast($0) }
                    ), format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                    Text("%")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Pre-ferment")
        } footer: {
            if viewModel.recipe.preFerment.isEnabled {
                Text(viewModel.recipe.preFerment.type.description)
            }
        }
    }
}

#Preview {
    Form {
        PreFermentSection()
    }
    .environment(RecipeViewModel())
}
