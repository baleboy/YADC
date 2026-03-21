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

    init(recipe: Recipe?, initialMode: CalculatorMode = .forward) {
        self.originalRecipe = recipe
        self.initialMode = (recipe != nil ? .forward : initialMode)
        _viewModel = State(initialValue: RecipeViewModel(recipe: recipe))
        _selectedTab = State(initialValue: initialMode == .reverse && recipe == nil ? .weight : .percentage)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Recipe name field
                VStack(alignment: .leading, spacing: 4) {
                    Text(originalRecipe == nil ? "New Recipe" : "Editor")
                        .font(AppFont.serifHeadline(28))
                        .foregroundStyle(Color("TextPrimary"))

                    TextField("Recipe Name", text: $viewModel.recipe.name)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color("TextPrimary"))
                        .padding(12)
                        .background(Color("SurfaceContainerHigh"))
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                }
                .padding(16)
                .background(Color("CreamBackground"))

                // Tab bar
                TabView(selection: $selectedTab) {
                    if initialMode == .forward {
                        PercentageModeView()
                            .tabItem {
                                Label("Recipe", systemImage: "percent")
                            }
                            .tag(EditorTab.percentage)
                    }

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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.discardChanges()
                        dismiss()
                    }
                    .foregroundStyle(Color("TextSecondary"))
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
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 7)
                                .background(Color("AccentColor"))
                                .clipShape(Capsule())
                        }
                    } else {
                        Button {
                            saveAndDismiss()
                        } label: {
                            Text("Save")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 7)
                                .background(Color("AccentColor"))
                                .clipShape(Capsule())
                        }
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
