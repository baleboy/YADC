//
//  RecipeListView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 14.12.2025.
//

import SwiftUI

struct RecipeListView: View {
    @Environment(RecipeStore.self) private var store
    @State private var showingEntryModePicker = false
    @State private var selectedRecipe: Recipe?

    var body: some View {
        NavigationStack {
            Group {
                if store.recipes.isEmpty {
                    ContentUnavailableView {
                        Label("No Recipes", systemImage: "doc.text")
                    } description: {
                        Text("Tap the + button to create your first recipe")
                    }
                } else {
                    List {
                        ForEach(store.recipes) { recipe in
                            NavigationLink(value: recipe) {
                                RecipeRowView(recipe: recipe)
                            }
                            .listRowBackground(Color("FormRowBackground"))
                        }
                        .onDelete(perform: deleteRecipes)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Color("CreamBackground"))
            .navigationTitle("Recipes")
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingEntryModePicker = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .toolbarBackground(Color("CreamBackground"), for: .navigationBar)
            .fullScreenCover(isPresented: $showingEntryModePicker) {
                NewRecipeEntryModeView()
            }
        }
    }

    private func deleteRecipes(at offsets: IndexSet) {
        store.deleteRecipes(at: offsets)
    }
}

#Preview {
    RecipeListView()
        .environment(RecipeStore())
}
