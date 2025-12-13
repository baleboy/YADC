//
//  IngredientRowView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import SwiftUI

struct IngredientRowView: View {
    @Environment(RecipeViewModel.self) private var viewModel
    let ingredient: Ingredient

    var body: some View {
        if viewModel.mode == .forward && !ingredient.isFlour && !ingredient.isWater {
            VStack {
                HStack {
                    Text(ingredient.name)
                    Spacer()
                    forwardModeContent
                }
                Slider(
                    value: Binding(
                        get: { ingredient.percentage },
                        set: { viewModel.updateIngredientPercentage(id: ingredient.id, percentage: $0) }
                    ),
                    in: 0...30,
                    step: 0.5
                )
            }
        } else {
            HStack {
                Text(ingredient.name)
                Spacer()
                if viewModel.mode == .forward {
                    forwardModeContent
                } else {
                    reverseModeContent
                }
            }
        }
    }

    @ViewBuilder
    private var forwardModeContent: some View {
        if ingredient.isFlour || ingredient.isWater {
            // Flour and water show read-only percentage and weight
            // (water is controlled via the Hydration section)
            Text(ingredient.percentage.percentageFormatted)
                .foregroundStyle(.secondary)
            Text("|")
                .foregroundStyle(.quaternary)
            Text("\(viewModel.displayWeight(ingredient.weight).weightFormatted) \(viewModel.weightUnit)")
                .foregroundStyle(.secondary)
        } else {
            TextField("", value: Binding(
                get: { ingredient.percentage },
                set: { viewModel.updateIngredientPercentage(id: ingredient.id, percentage: $0) }
            ), format: .number.precision(.fractionLength(0...1)))
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .frame(width: 50)
            .textFieldStyle(.roundedBorder)
            Text("%")
                .foregroundStyle(.secondary)
            Text("|")
                .foregroundStyle(.quaternary)
            Text("\(viewModel.displayWeight(ingredient.weight).weightFormatted) \(viewModel.weightUnit)")
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var reverseModeContent: some View {
        Text(ingredient.percentage.percentageFormatted)
            .foregroundStyle(.secondary)
        Text("|")
            .foregroundStyle(.quaternary)
        TextField("", value: Binding(
            get: { viewModel.displayWeight(ingredient.weight) },
            set: { viewModel.updateIngredientWeight(id: ingredient.id, weight: viewModel.weightFromInput($0)) }
        ), format: .number.precision(.fractionLength(0...1)))
        .keyboardType(.decimalPad)
        .multilineTextAlignment(.trailing)
        .frame(width: 60)
        .textFieldStyle(.roundedBorder)
        Text(viewModel.weightUnit)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    Form {
        IngredientRowView(ingredient: Ingredient(name: "Salt", percentage: 2.5, weight: 15))
    }
    .environment(RecipeViewModel())
}
