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
            .scrollContentBackground(.hidden)
            .background(Color("CreamBackground"))
            .foregroundStyle(Color("TextPrimary"))
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Dough Calculator")
            .toolbarBackground(Color("CreamBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
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
