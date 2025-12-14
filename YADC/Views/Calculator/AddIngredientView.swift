//
//  AddIngredientView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import SwiftUI

struct AddIngredientView: View {
    @Environment(RecipeViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    let mode: CalculatorMode
    let weightUnit: String

    @State private var name = ""
    @State private var percentage = 1.0
    @State private var weight = 10.0
    @State private var hydrationContribution: HydrationContribution = .none
    @State private var ingredientType: IngredientType = .regular
    @State private var preFermentType: PreFermentType = .poolish
    @State private var preFermentWeight = 200.0
    @State private var yeastPercentage = 0.1
    @State private var customHydration = 75.0

    private var flourWeight: Double {
        viewModel.recipe.flour?.weight ?? 0
    }

    private var calculatedWeight: Double {
        viewModel.displayWeight(flourWeight * percentage / 100)
    }

    private var calculatedPercentage: Double {
        guard flourWeight > 0 else { return 0 }
        return viewModel.weightFromInput(weight) / flourWeight * 100
    }

    private var availableHydrationContributions: [HydrationContribution] {
        // In forward mode, water is controlled by hydration slider, so don't allow adding water ingredients
        if mode == .forward {
            return HydrationContribution.allCases.filter { $0 != .water }
        }
        return HydrationContribution.allCases.map { $0 }
    }

    private var preFermentHydration: Double {
        preFermentType == .custom ? customHydration : preFermentType.defaultHydration
    }

    private var preFermentBreakdown: (flour: Double, water: Double, yeast: Double) {
        let metadata = PreFermentMetadata(
            type: preFermentType,
            hydration: preFermentHydration,
            yeastPercentage: yeastPercentage
        )
        let flourWeight = preFermentWeight / metadata.totalRatio
        let waterWeight = flourWeight * metadata.waterRatio
        let yeastWeight = flourWeight * metadata.yeastRatio
        return (flourWeight, waterWeight, yeastWeight)
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $ingredientType) {
                    Text("Regular").tag(IngredientType.regular)
                    Text("Pre-ferment").tag(IngredientType.preFerment)
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color("FormRowBackground"))

                if ingredientType == .regular {
                    regularIngredientFields()
                } else {
                    preFermentFields()
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("CreamBackground"))
            .foregroundStyle(Color("TextPrimary"))
            .navigationTitle(ingredientType == .regular ? "Add Ingredient" : "Add Pre-ferment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("CreamBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if ingredientType == .regular {
                            addRegularIngredient()
                        } else {
                            addPreFerment()
                        }
                        dismiss()
                    }
                    .disabled(ingredientType == .regular ? name.isEmpty : false)
                }
            }
        }
    }

    @ViewBuilder
    private func regularIngredientFields() -> some View {
        TextField("Ingredient name", text: $name)
            .listRowBackground(Color("FormRowBackground"))

        if mode == .forward {
                    VStack {
                        HStack {
                            Text("Percentage")
                            Spacer()
                            TextField("", value: $percentage, format: .number.precision(.fractionLength(0...1)))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 60)
                                .themedTextField()
                            Text("%")
                                .foregroundStyle(Color("TextSecondary"))
                        }
                        Slider(value: $percentage, in: 0...30, step: 0.5)
                            .tint(Color("AccentColor"))
                    }
                    .listRowBackground(Color("FormRowBackground"))

                    HStack {
                        Text("Weight")
                        Spacer()
                        Text("\(calculatedWeight.weightFormatted) \(weightUnit)")
                            .foregroundStyle(Color("TextSecondary"))
                    }
                    .listRowBackground(Color("FormRowBackground"))
                } else {
                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField("", value: $weight, format: .number.precision(.fractionLength(0...1)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .themedTextField()
                        Text(weightUnit)
                            .foregroundStyle(Color("TextSecondary"))
                    }
                    .listRowBackground(Color("FormRowBackground"))

                    HStack {
                        Text("Percentage")
                        Spacer()
                        Text(calculatedPercentage.percentageFormatted)
                            .foregroundStyle(Color("TextSecondary"))
                    }
                    .listRowBackground(Color("FormRowBackground"))
                }

        Picker("Type", selection: $hydrationContribution) {
            ForEach(availableHydrationContributions) { contribution in
                Text(contribution.displayName).tag(contribution)
            }
        }
        .tint(Color("AccentColor"))
        .listRowBackground(Color("FormRowBackground"))
    }

    @ViewBuilder
    private func preFermentFields() -> some View {
        Picker("Pre-ferment Type", selection: $preFermentType) {
            ForEach(PreFermentType.allCases) { type in
                Text(type.displayName).tag(type)
            }
        }
        .tint(Color("AccentColor"))
        .listRowBackground(Color("FormRowBackground"))

        HStack {
            Text("Total Weight")
            Spacer()
            TextField("", value: $preFermentWeight, format: .number.precision(.fractionLength(0...1)))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 60)
                .themedTextField()
            Text(weightUnit)
                .foregroundStyle(Color("TextSecondary"))
        }
        .listRowBackground(Color("FormRowBackground"))

        VStack {
            HStack {
                Text("Yeast Percentage")
                Spacer()
                TextField("", value: $yeastPercentage, format: .number.precision(.fractionLength(0...2)))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                    .themedTextField()
                Text("%")
                    .foregroundStyle(Color("TextSecondary"))
            }
            Slider(value: $yeastPercentage, in: 0...2, step: 0.1)
                .tint(Color("AccentColor"))
        }
        .listRowBackground(Color("FormRowBackground"))

        if preFermentType == .custom {
            VStack {
                HStack {
                    Text("Hydration")
                    Spacer()
                    TextField("", value: $customHydration, format: .number.precision(.fractionLength(0...1)))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                        .themedTextField()
                    Text("%")
                        .foregroundStyle(Color("TextSecondary"))
                }
                Slider(value: $customHydration, in: 40...120, step: 5)
                    .tint(Color("AccentColor"))
            }
            .listRowBackground(Color("FormRowBackground"))
        } else {
            HStack {
                Text("Hydration")
                Spacer()
                Text("\(Int(preFermentHydration))%")
                    .foregroundStyle(Color("TextSecondary"))
            }
            .listRowBackground(Color("FormRowBackground"))
        }

        Section("Breakdown") {
            HStack {
                Text("Flour")
                Spacer()
                Text("\(viewModel.displayWeight(preFermentBreakdown.flour).weightFormatted) \(weightUnit)")
                    .foregroundStyle(Color("TextSecondary"))
            }
            .listRowBackground(Color("FormRowBackground"))

            HStack {
                Text("Water")
                Spacer()
                Text("\(viewModel.displayWeight(preFermentBreakdown.water).weightFormatted) \(weightUnit)")
                    .foregroundStyle(Color("TextSecondary"))
            }
            .listRowBackground(Color("FormRowBackground"))

            HStack {
                Text("Yeast")
                Spacer()
                Text("\(viewModel.displayWeight(preFermentBreakdown.yeast).weightFormatted) \(weightUnit)")
                    .foregroundStyle(Color("TextSecondary"))
            }
            .listRowBackground(Color("FormRowBackground"))
        }
    }

    private func addRegularIngredient() {
        if mode == .forward {
            viewModel.addIngredient(
                name: name,
                percentage: percentage,
                hydrationContribution: hydrationContribution
            )
        } else {
            viewModel.addIngredientByWeight(
                name: name,
                weight: viewModel.weightFromInput(weight),
                hydrationContribution: hydrationContribution
            )
        }
    }

    private func addPreFerment() {
        viewModel.addPreFerment(
            type: preFermentType,
            totalWeight: viewModel.weightFromInput(preFermentWeight),
            yeastPercentage: yeastPercentage
        )
    }
}

#Preview {
    AddIngredientView(mode: .forward, weightUnit: "g")
        .environment(RecipeViewModel())
}
