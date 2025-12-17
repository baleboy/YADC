//
//  RecipeEditorView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 14.12.2025.
//

import SwiftUI

enum EditorTab: String, CaseIterable {
    case percentage = "By Percentage"
    case weight = "By Weight"
    case steps = "Steps"
    case preview = "Preview"
}

struct RecipeEditorView: View {
    @Environment(RecipeStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let originalRecipe: Recipe?
    let initialMode: CalculatorMode
    @State private var viewModel: RecipeViewModel
    @State private var selectedTab: EditorTab = .percentage
    @State private var showingAddStep = false

    /// For new recipes, specify the initial mode. For editing, mode is always forward.
    init(recipe: Recipe?, initialMode: CalculatorMode = .forward) {
        self.originalRecipe = recipe
        // When editing an existing recipe, always use forward mode
        self.initialMode = (recipe != nil ? .forward : initialMode)
        _viewModel = State(initialValue: RecipeViewModel(recipe: recipe))
        // Set initial tab based on mode
        _selectedTab = State(initialValue: initialMode == .reverse && recipe == nil ? .weight : .percentage)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Recipe name field
                HStack {
                    TextField("Recipe Name", text: $viewModel.recipe.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("TextPrimary"))
                }
                .padding()
                .background(Color("CreamBackground"))

                // Tab bar - show only relevant mode tab based on initialMode
                TabView(selection: $selectedTab) {
                    // Show percentage tab for forward mode or when editing existing recipes
                    if initialMode == .forward {
                        PercentageModeView()
                            .tabItem {
                                Label("Recipe", systemImage: "percent")
                            }
                            .tag(EditorTab.percentage)
                    }

                    // Show weight tab only for new recipes in reverse mode
                    if initialMode == .reverse && originalRecipe == nil {
                        WeightModeView()
                            .tabItem {
                                Label("Recipe", systemImage: "scalemass")
                            }
                            .tag(EditorTab.weight)
                    }

                    StepsEditorView()
                        .tabItem {
                            Label("Steps", systemImage: "list.number")
                        }
                        .tag(EditorTab.steps)

                    RecipePreviewView()
                        .tabItem {
                            Label("Preview", systemImage: "eye")
                        }
                        .tag(EditorTab.preview)
                }
                .environment(viewModel)
                .toolbarBackground(Color("CreamBackground"), for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
            }
            .background(Color("CreamBackground"))
            .navigationTitle(originalRecipe == nil ? "New Recipe" : "Edit Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("CreamBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.discardChanges()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .principal) {
                    if selectedTab == .steps {
                        Button {
                            showingAddStep = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if originalRecipe != nil {
                        Menu {
                            Button("Save") {
                                saveAndDismiss()
                            }
                            Button("Save as New Recipe") {
                                saveAsNewAndDismiss()
                            }
                        } label: {
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                    } else {
                        Button("Save") {
                            saveAndDismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingAddStep) {
                AddStepView()
                    .environment(viewModel)
            }
        }
        .onAppear {
            viewModel.store = store
            // Set mode once based on initialMode
            if initialMode == .reverse {
                viewModel.switchToReverseMode()
            } else {
                viewModel.switchToForwardMode()
            }
        }
    }

    private func saveAndDismiss() {
        let savedRecipe = viewModel.saveChanges()

        if originalRecipe == nil {
            store.addRecipe(savedRecipe)
        } else {
            store.updateRecipe(savedRecipe)
        }

        dismiss()
    }

    private func saveAsNewAndDismiss() {
        let savedRecipe = viewModel.saveChanges()
        let newRecipe = Recipe(
            id: UUID(),
            name: savedRecipe.name,
            numberOfBalls: savedRecipe.numberOfBalls,
            weightPerBall: savedRecipe.weightPerBall,
            hydration: savedRecipe.hydration,
            ingredients: savedRecipe.ingredients,
            steps: savedRecipe.steps,
            createdAt: Date(),
            updatedAt: Date()
        )
        store.addRecipe(newRecipe)
        dismiss()
    }
}

#Preview {
    RecipeEditorView(recipe: nil)
        .environment(RecipeStore())
}
