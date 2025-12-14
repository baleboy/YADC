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
                    .tint(Color("AccentColor"))
                    .listRowBackground(Color("FormRowBackground"))
                }

                if viewModel.recipe.preFerment.isEnabled {
                    Section("Pre-ferment (\(viewModel.recipe.preFerment.type.displayName))") {
                        RecipeIngredientRow(
                            name: "Flour",
                            weight: viewModel.displayWeight(viewModel.recipe.preFerment.flourWeight),
                            unit: viewModel.weightUnit
                        )
                        .listRowBackground(Color("FormRowBackground"))
                        RecipeIngredientRow(
                            name: "Water",
                            weight: viewModel.displayWeight(viewModel.recipe.preFerment.waterWeight),
                            unit: viewModel.weightUnit
                        )
                        .listRowBackground(Color("FormRowBackground"))
                        RecipeIngredientRow(
                            name: "Yeast",
                            weight: viewModel.displayWeight(viewModel.recipe.preFerment.yeastWeight),
                            unit: viewModel.weightUnit
                        )
                        .listRowBackground(Color("FormRowBackground"))
                    }
                }

                Section("Main Dough") {
                    ForEach(viewModel.recipe.ingredients) { ingredient in
                        RecipeIngredientRow(
                            name: ingredient.name,
                            weight: viewModel.displayWeight(ingredient.weight),
                            unit: viewModel.weightUnit
                        )
                        .listRowBackground(Color("FormRowBackground"))
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
                    .listRowBackground(Color("FormRowBackground"))
                }

                if !viewModel.recipe.steps.isEmpty {
                    Section("Steps") {
                        ForEach(Array(viewModel.recipe.steps.enumerated()), id: \.element.id) { index, step in
                            RecipeStepRow(step: step, stepNumber: index + 1)
                                .listRowBackground(Color("FormRowBackground"))
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("CreamBackground"))
            .foregroundStyle(Color("TextPrimary"))
            .navigationTitle("Recipe")
            .toolbarBackground(Color("CreamBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
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
                .foregroundStyle(Color("TextSecondary"))
        }
    }
}

#Preview {
    RecipeView()
        .environment(RecipeViewModel())
}
