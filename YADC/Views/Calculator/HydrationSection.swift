//
//  HydrationSection.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import SwiftUI

struct HydrationSection: View {
    @Environment(RecipeViewModel.self) private var viewModel

    var body: some View {
        Section("Hydration") {
            if viewModel.mode == .forward {
                HStack {
                    Text("Hydration")
                    Spacer()
                    TextField("Hydration", value: Binding(
                        get: { viewModel.recipe.hydration },
                        set: { viewModel.updateHydration($0) }
                    ), format: .number.precision(.fractionLength(0...1)))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                    .themedTextField()
                    Text("%")
                        .foregroundStyle(Color("TextSecondary"))
                }
                .listRowBackground(Color("FormRowBackground"))

                Slider(
                    value: Binding(
                        get: { viewModel.recipe.hydration },
                        set: { viewModel.updateHydration($0) }
                    ),
                    in: 50...100,
                    step: 1
                )
                .tint(Color("AccentColor"))
                .listRowBackground(Color("FormRowBackground"))
            } else {
                HStack {
                    Text("Calculated Hydration")
                    Spacer()
                    Text(viewModel.recipe.hydration.percentageFormatted)
                        .foregroundStyle(Color("TextSecondary"))
                }
                .listRowBackground(Color("FormRowBackground"))
            }
        }
    }
}

#Preview {
    Form {
        HydrationSection()
    }
    .environment(RecipeViewModel())
}
