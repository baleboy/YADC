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
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("My Recipes")
                            .font(AppFont.serifHeadline(34))
                            .foregroundStyle(Color("TextPrimary"))

                        Text("\(store.recipes.count) recipe\(store.recipes.count == 1 ? "" : "s") in your collection")
                            .font(.subheadline)
                            .foregroundStyle(Color("TextSecondary"))
                    }
                    .padding(.horizontal)

                    // Search bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color("TextTertiary"))
                        TextField("Search your library...", text: $searchText)
                            .foregroundStyle(Color("TextPrimary"))
                    }
                    .padding(14)
                    .background(Color("FormRowBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))
                    .padding(.horizontal)

                    if filteredRecipes.isEmpty {
                        ContentUnavailableView {
                            Label(searchText.isEmpty ? "No Recipes" : "No Results", systemImage: "doc.text")
                        } description: {
                            Text(searchText.isEmpty ? "Tap the + button to create your first recipe" : "No recipes match your search")
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
                    } else {
                        // Recipe cards
                        LazyVStack(spacing: 20) {
                            ForEach(filteredRecipes) { recipe in
                                NavigationLink(value: recipe) {
                                    RecipeRowView(recipe: recipe)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
            .background(Color("CreamBackground"))
            .navigationTitle("Autolyse")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Autolyse")
                        .font(AppFont.serifHeadline(18))
                        .foregroundStyle(Color("AccentColor"))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingEntryModePicker = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(Color("AccentColor"))
                            .clipShape(Circle())
                    }
                }
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
