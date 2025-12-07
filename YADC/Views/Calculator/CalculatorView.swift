//
//  CalculatorView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import SwiftUI

struct CalculatorView: View {
    @Environment(RecipeViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            Form {
                DoughParametersSection()
                ModeToggleView()
                HydrationSection()
                IngredientsListView()
                PreFermentSection()
            }
            .navigationTitle("Dough Calculator")
        }
    }
}

#Preview {
    CalculatorView()
        .environment(RecipeViewModel())
}
