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
                    HStack {
                        Text("Percentage")
                        Spacer()
                        TextField("", value: $percentage, format: .number.precision(.fractionLength(0...1)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text("%")
                            .foregroundStyle(.secondary)
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
                            viewModel.addIngredient(name: name, percentage: percentage)
                        } else {
                            viewModel.addIngredientByWeight(
                                name: name,
                                weight: viewModel.weightFromInput(weight)
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
