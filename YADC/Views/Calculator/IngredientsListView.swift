//
//  IngredientsListView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import SwiftUI

struct IngredientsListView: View {
    @Environment(RecipeViewModel.self) private var viewModel
    @State private var showingAddIngredient = false

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
        .sheet(isPresented: $showingAddIngredient) {
            AddIngredientView()
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
    Form {
        IngredientsListView()
    }
    .environment(RecipeViewModel())
}
