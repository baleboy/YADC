//
//  ModeToggleView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import SwiftUI

struct ModeToggleView: View {
    @Environment(RecipeViewModel.self) private var viewModel

    var body: some View {
        Section {
            Picker("Mode", selection: Binding(
                get: { viewModel.mode },
                set: { newMode in
                    if newMode == .forward {
                        viewModel.switchToForwardMode()
                    } else {
                        viewModel.switchToReverseMode()
                    }
                }
            )) {
                Text("By Percentage").tag(CalculatorMode.forward)
                Text("By Weight").tag(CalculatorMode.reverse)
            }
            .pickerStyle(.segmented)
            .tint(Color("AccentColor"))
            .listRowBackground(Color("FormRowBackground"))
        } footer: {
            Text(viewModel.mode == .forward
                 ? "Enter percentages to calculate weights"
                 : "Enter weights to calculate hydration")
        }
    }
}

#Preview {
    Form {
        ModeToggleView()
    }
    .environment(RecipeViewModel())
}
