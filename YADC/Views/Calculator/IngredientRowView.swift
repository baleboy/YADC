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
        if ingredient.isPreFerment {
            preFermentView
        } else if viewModel.mode == .forward && !ingredient.isFlour && !ingredient.isWater {
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
                .tint(Color("AccentColor"))
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
                .foregroundStyle(Color("TextSecondary"))
            Text("|")
                .foregroundStyle(Color("TextTertiary"))
            Text("\(viewModel.displayWeight(ingredient.weight).weightFormatted) \(viewModel.weightUnit)")
                .foregroundStyle(Color("TextSecondary"))
        } else {
            TextField("", value: Binding(
                get: { ingredient.percentage },
                set: { viewModel.updateIngredientPercentage(id: ingredient.id, percentage: $0) }
            ), format: .number.precision(.fractionLength(0...1)))
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .frame(width: 50)
            .themedTextField()
            Text("%")
                .foregroundStyle(Color("TextSecondary"))
            Text("|")
                .foregroundStyle(Color("TextTertiary"))
            Text("\(viewModel.displayWeight(ingredient.weight).weightFormatted) \(viewModel.weightUnit)")
                .foregroundStyle(Color("TextSecondary"))
        }
    }

    @ViewBuilder
    private var reverseModeContent: some View {
        Text(ingredient.percentage.percentageFormatted)
            .foregroundStyle(Color("TextSecondary"))
        Text("|")
            .foregroundStyle(Color("TextTertiary"))
        TextField("", value: Binding(
            get: { viewModel.displayWeight(ingredient.weight) },
            set: { viewModel.updateIngredientWeight(id: ingredient.id, weight: viewModel.weightFromInput($0)) }
        ), format: .number.precision(.fractionLength(0...1)))
        .keyboardType(.decimalPad)
        .multilineTextAlignment(.trailing)
        .frame(width: 60)
        .textFieldStyle(.roundedBorder)
        Text(viewModel.weightUnit)
            .foregroundStyle(Color("TextSecondary"))
    }

    @ViewBuilder
    private var preFermentView: some View {
        DisclosureGroup {
            if let subIngredients = ingredient.subIngredients {
                ForEach(subIngredients) { sub in
                    HStack {
                        Text("  \(sub.name)")
                            .font(.caption)
                        Spacer()
                        Text("\(viewModel.displayWeight(sub.weight).weightFormatted) \(viewModel.weightUnit)")
                            .font(.caption)
                            .foregroundStyle(Color("TextSecondary"))
                    }
                }
            }
        } label: {
            HStack {
                Text(ingredient.name)
                    .font(.body.weight(.medium))
                if let metadata = ingredient.preFermentMetadata {
                    Text("(\(metadata.type.displayName))")
                        .font(.caption)
                        .foregroundStyle(Color("TextSecondary"))
                }
                Spacer()
                if viewModel.mode == .reverse {
                    TextField("", value: Binding(
                        get: { viewModel.displayWeight(ingredient.weight) },
                        set: { viewModel.updatePreFermentWeight(id: ingredient.id, totalWeight: viewModel.weightFromInput($0)) }
                    ), format: .number.precision(.fractionLength(0...1)))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)
                } else {
                    Text("\(viewModel.displayWeight(ingredient.weight).weightFormatted)")
                        .foregroundStyle(Color("TextSecondary"))
                }
                Text(viewModel.weightUnit)
                    .foregroundStyle(Color("TextSecondary"))
            }
        }
        .tint(Color("AccentColor"))
    }
}

#Preview {
    Form {
        IngredientRowView(ingredient: Ingredient(name: "Salt", percentage: 2.5, weight: 15))
    }
    .environment(RecipeViewModel())
}
