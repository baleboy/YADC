//
//  CalculatorView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import SwiftUI

struct CalculatorView: View {
    @Environment(RecipeViewModel.self) private var viewModel
    @State private var showingAddIngredient = false

    var body: some View {
        NavigationStack {
            Form {
                DoughParametersSection()
                ModeToggleView()
                HydrationSection()
                IngredientsListView(showingAddIngredient: $showingAddIngredient)
                PreFermentSection()
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Dough Calculator")
            .sheet(isPresented: $showingAddIngredient) {
                AddIngredientView(mode: viewModel.mode, weightUnit: viewModel.weightUnit)
            }
        }
    }
}

#Preview {
    CalculatorView()
        .environment(RecipeViewModel())
}
