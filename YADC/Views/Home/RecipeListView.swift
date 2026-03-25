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
    @State private var searchText = ""

    private var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return store.recipes
        }
        return store.recipes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("Autolyse")
                            .font(AppFont.heading(26))
                            .tracking(-0.5)
                            .foregroundStyle(Color("TextPrimary"))

                        Spacer()

                        Button {
                            showingEntryModePicker = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                                .background(Color("AccentColor"))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)

                    // Search bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15))
                            .foregroundStyle(Color("TextTertiary"))
                        TextField("Search recipes...", text: $searchText)
                            .font(AppFont.body(15))
                            .foregroundStyle(Color("TextPrimary"))
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .background(Color("FormRowBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                    .padding(.horizontal, 20)

                    if filteredRecipes.isEmpty {
                        ContentUnavailableView {
                            Label(searchText.isEmpty ? "No Recipes" : "No Results", systemImage: "doc.text")
                        } description: {
                            Text(searchText.isEmpty ? "Tap the + button to create your first recipe" : "No recipes match your search")
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
                    } else {
                        // Recipe cards
                        LazyVStack(spacing: 12) {
                            ForEach(filteredRecipes) { recipe in
                                NavigationLink(value: recipe) {
                                    RecipeRowView(recipe: recipe)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
            .background(Color("CreamBackground"))
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .fullScreenCover(isPresented: $showingEntryModePicker) {
                NewRecipeEntryModeView()
                    .environment(store)
            }
        }
    }
}

#Preview {
    RecipeListView()
        .environment(RecipeStore())
        .environment(JournalStore())
}
