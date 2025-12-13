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

    var body: some View {
        NavigationStack {
            Form {
                TextField("Ingredient name", text: $name)

                if mode == .forward {
                    VStack {
                        HStack {
                            Text("Percentage")
                            Spacer()
                            TextField("", value: $percentage, format: .number.precision(.fractionLength(0...1)))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 60)
                                .textFieldStyle(.roundedBorder)
                            Text("%")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $percentage, in: 0...30, step: 0.5)
                    }

                    HStack {
                        Text("Weight")
                        Spacer()
                        Text("\(calculatedWeight.weightFormatted) \(weightUnit)")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField("", value: $weight, format: .number.precision(.fractionLength(0...1)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .textFieldStyle(.roundedBorder)
                        Text(weightUnit)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Percentage")
                        Spacer()
                        Text(calculatedPercentage.percentageFormatted)
                            .foregroundStyle(.secondary)
                    }
                }

                Picker("Type", selection: $hydrationContribution) {
                    ForEach(HydrationContribution.allCases) { contribution in
                        Text(contribution.displayName).tag(contribution)
                    }
                }
            }
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
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
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddIngredientView(mode: .forward, weightUnit: "g")
        .environment(RecipeViewModel())
}
