//
//  RecipeView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 13.12.2025.
//

import SwiftUI

struct RecipeView: View {
    @Environment(RecipeViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Stepper("Number of balls: \(viewModel.recipe.numberOfBalls)",
                            value: Binding(
                                get: { viewModel.recipe.numberOfBalls },
                                set: { viewModel.updateNumberOfBalls($0) }
                            ),
                            in: 1...100)
                }

                if viewModel.recipe.preFerment.isEnabled {
                    Section("Pre-ferment (\(viewModel.recipe.preFerment.type.displayName))") {
                        RecipeIngredientRow(
                            name: "Flour",
                            weight: viewModel.displayWeight(viewModel.recipe.preFerment.flourWeight),
                            unit: viewModel.weightUnit
                        )
                        RecipeIngredientRow(
                            name: "Water",
                            weight: viewModel.displayWeight(viewModel.recipe.preFerment.waterWeight),
                            unit: viewModel.weightUnit
                        )
                        RecipeIngredientRow(
                            name: "Yeast",
                            weight: viewModel.displayWeight(viewModel.recipe.preFerment.yeastWeight),
                            unit: viewModel.weightUnit
                        )
                    }
                }

                Section("Main Dough") {
                    ForEach(viewModel.recipe.ingredients) { ingredient in
                        RecipeIngredientRow(
                            name: ingredient.name,
                            weight: viewModel.displayWeight(ingredient.weight),
                            unit: viewModel.weightUnit
                        )
                    }
                }

                Section {
                    HStack {
                        Text("Total dough weight")
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(viewModel.displayWeight(viewModel.recipe.totalDoughWeight).weightFormatted) \(viewModel.weightUnit)")
                            .fontWeight(.medium)
                    }
                }
            }
            .navigationTitle("Recipe")
        }
    }
}

struct RecipeIngredientRow: View {
    let name: String
    let weight: Double
    let unit: String

    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Text("\(weight.weightFormatted) \(unit)")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    RecipeView()
        .environment(RecipeViewModel())
}
