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

                if let preFerment = viewModel.recipe.ingredients.first(where: { $0.isPreFerment }) {
                    Section("Pre-ferment (\(preFerment.preFermentMetadata?.type.displayName ?? ""))") {
                        RecipeIngredientRow(
                            name: "Total",
                            weight: viewModel.displayWeight(preFerment.weight),
                            unit: viewModel.weightUnit
                        )
                        .listRowBackground(Color("FormRowBackground"))

                        if let subIngredients = preFerment.subIngredients {
                            ForEach(subIngredients) { sub in
                                RecipeIngredientRow(
                                    name: "  \(sub.name)",
                                    weight: viewModel.displayWeight(sub.weight),
                                    unit: viewModel.weightUnit
                                )
                                .font(.caption)
                                .listRowBackground(Color("FormRowBackground"))
                            }
                        }
                    }
                }

                Section("Main Dough") {
                    ForEach(viewModel.recipe.ingredients.filter { !$0.isPreFerment }) { ingredient in
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
