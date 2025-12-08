//
//  IngredientsListView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import SwiftUI

struct IngredientsListView: View {
    @Environment(RecipeViewModel.self) private var viewModel
    @Binding var showingAddIngredient: Bool

    var body: some View {
        Section("Ingredients") {
            ForEach(viewModel.recipe.ingredients) { ingredient in
                IngredientRowView(ingredient: ingredient)
            }
            .onDelete(perform: deleteIngredients)

            Button {
                showingAddIngredient = true
            } label: {
                Label("Add Ingredient", systemImage: "plus.circle")
            }
        }
    }

    private func deleteIngredients(at offsets: IndexSet) {
        for index in offsets {
            let ingredient = viewModel.recipe.ingredients[index]
            if !ingredient.isCore {
                viewModel.removeIngredient(id: ingredient.id)
            }
        }
    }
}

#Preview {
    @Previewable @State var showingAddIngredient = false
    Form {
        IngredientsListView(showingAddIngredient: $showingAddIngredient)
    }
    .environment(RecipeViewModel())
}
