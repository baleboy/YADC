//
//  RecipePreviewView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 14.12.2025.
//

import SwiftUI

struct RecipePreviewView: View {
    @Environment(RecipeViewModel.self) private var viewModel

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Number of balls")
                    Spacer()
                    Text("\(viewModel.recipe.numberOfBalls)")
                        .foregroundStyle(Color("TextSecondary"))
                }
                .listRowBackground(Color("FormRowBackground"))
            }

            if let preFerment = viewModel.recipe.ingredients.first(where: { $0.isPreFerment }) {
                Section("Pre-ferment (\(preFerment.preFermentMetadata?.type.displayName ?? ""))") {
                    PreviewIngredientRow(
                        name: "Total",
                        weight: viewModel.displayWeight(preFerment.weight),
                        unit: viewModel.weightUnit
                    )
                    .listRowBackground(Color("FormRowBackground"))

                    if let subIngredients = preFerment.subIngredients {
                        ForEach(subIngredients) { sub in
                            PreviewIngredientRow(
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
                    PreviewIngredientRow(
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
                        PreviewStepRow(step: step, stepNumber: index + 1, viewModel: viewModel)
                            .listRowBackground(Color("FormRowBackground"))
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color("CreamBackground"))
        .foregroundStyle(Color("TextPrimary"))
    }
}

struct PreviewIngredientRow: View {
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

struct PreviewStepRow: View {
    let step: Step
    let stepNumber: Int
    let viewModel: RecipeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text("\(stepNumber).")
                    .foregroundStyle(Color("TextSecondary"))
                    .frame(width: 24, alignment: .leading)
                Text(step.description)
            }

            if step.waitingTimeMinutes != nil || step.temperatureCelsius != nil {
                HStack(spacing: 16) {
                    if let minutes = step.waitingTimeMinutes, minutes > 0 {
                        Label(formatDuration(minutes), systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(Color("TextSecondary"))
                    }

                    if let temp = step.temperatureCelsius {
                        Label(
                            "\(Int(viewModel.displayTemperature(temp)))\(viewModel.temperatureUnit)",
                            systemImage: "thermometer.medium"
                        )
                        .font(.caption)
                        .foregroundStyle(Color("TextSecondary"))
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func formatDuration(_ minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(hours)h"
            }
            return "\(hours)h \(mins)m"
        }
        return "\(minutes) min"
    }
}

#Preview {
    RecipePreviewView()
        .environment(RecipeViewModel())
}
