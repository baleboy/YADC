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
    @State private var viewModel: RecipeViewModel
    @State private var selectedTab: EditorTab = .percentage
    @State private var showingAddStep = false

    init(recipe: Recipe?) {
        self.originalRecipe = recipe
        _viewModel = State(initialValue: RecipeViewModel(recipe: recipe))
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

                // Tab bar for mode switching
                TabView(selection: $selectedTab) {
                    PercentageModeView()
                        .tabItem {
                            Label("By Percentage", systemImage: "percent")
                        }
                        .tag(EditorTab.percentage)

                    WeightModeView()
                        .tabItem {
                            Label("By Weight", systemImage: "scalemass")
                        }
                        .tag(EditorTab.weight)

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
            // Set initial mode based on tab
            if selectedTab == .weight {
                viewModel.switchToReverseMode()
            } else {
                viewModel.switchToForwardMode()
            }
        }
        .onChange(of: selectedTab) { _, newTab in
            switch newTab {
            case .percentage:
                viewModel.switchToForwardMode()
            case .weight:
                viewModel.switchToReverseMode()
            case .steps, .preview:
                break // No mode change for steps or preview
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
