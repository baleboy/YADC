//
//  DoughParametersSection.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import SwiftUI

struct DoughParametersSection: View {
    @Environment(RecipeViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel

        Section("Dough") {
            Stepper("Number of balls: \(viewModel.recipe.numberOfBalls)",
                    value: Binding(
                        get: { viewModel.recipe.numberOfBalls },
                        set: { viewModel.updateNumberOfBalls($0) }
                    ),
                    in: 1...100)
            .tint(Color("AccentColor"))
            .listRowBackground(Color("FormRowBackground"))

            HStack {
                Text("Weight per ball")
                Spacer()
                if viewModel.mode == .forward {
                    TextField("Weight", value: Binding(
                        get: { viewModel.displayWeight(viewModel.recipe.weightPerBall) },
                        set: { viewModel.updateWeightPerBall(viewModel.weightFromInput($0)) }
                    ), format: .number.precision(.fractionLength(0...1)))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                    .themedTextField()
                } else {
                    Text(viewModel.displayWeight(viewModel.recipe.weightPerBall).weightFormatted)
                }
                Text(viewModel.weightUnit)
                    .foregroundStyle(Color("TextSecondary"))
            }
            .listRowBackground(Color("FormRowBackground"))

            HStack {
                Text("Total dough weight")
                Spacer()
                Text("\(viewModel.displayWeight(viewModel.recipe.totalDoughWeight).weightFormatted) \(viewModel.weightUnit)")
                    .foregroundStyle(Color("TextSecondary"))
            }
            .listRowBackground(Color("FormRowBackground"))
        }
    }
}

#Preview {
    Form {
        DoughParametersSection()
    }
    .environment(RecipeViewModel())
}
