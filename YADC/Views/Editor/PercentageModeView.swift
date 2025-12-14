//
//  PercentageModeView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 14.12.2025.
//

import SwiftUI

struct PercentageModeView: View {
    @Environment(RecipeViewModel.self) private var viewModel
    @State private var showingAddIngredient = false

    var body: some View {
        Form {
            DoughParametersSection()
            HydrationSection()
            IngredientsListView(showingAddIngredient: $showingAddIngredient)
        }
        .scrollContentBackground(.hidden)
        .background(Color("CreamBackground"))
        .foregroundStyle(Color("TextPrimary"))
        .scrollDismissesKeyboard(.interactively)
        .sheet(isPresented: $showingAddIngredient) {
            AddIngredientView(mode: .forward, weightUnit: viewModel.weightUnit)
        }
    }
}

#Preview {
    PercentageModeView()
        .environment(RecipeViewModel())
}
