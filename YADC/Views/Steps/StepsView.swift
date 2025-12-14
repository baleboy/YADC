//
//  StepsView.swift
//  YADC
//
//  Created by Claude on 13.12.2025.
//

import SwiftUI

struct StepsView: View {
    @Environment(RecipeViewModel.self) private var viewModel
    @State private var showingAddStep = false
    @State private var editingStep: Step?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.recipe.steps.isEmpty {
                    ZStack {
                        Color("CreamBackground")
                            .ignoresSafeArea()
                        ContentUnavailableView(
                            "No Steps",
                            systemImage: "list.number",
                            description: Text("Add steps to your recipe")
                        )
                        .foregroundStyle(Color("TextPrimary"))
                    }
                } else {
                    List {
                        ForEach(viewModel.recipe.steps) { step in
                            StepRowView(step: step)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingStep = step
                                }
                                .listRowBackground(Color("FormRowBackground"))
                        }
                        .onMove(perform: moveSteps)
                        .onDelete(perform: deleteSteps)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color("CreamBackground"))
                    .foregroundStyle(Color("TextPrimary"))
                }
            }
            .navigationTitle("Steps")
            .toolbarBackground(Color("CreamBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !viewModel.recipe.steps.isEmpty {
                        EditButton()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddStep = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddStep) {
                AddStepView()
            }
            .sheet(item: $editingStep) { step in
                EditStepView(step: step)
            }
        }
    }

    private func moveSteps(from source: IndexSet, to destination: Int) {
        viewModel.moveStep(from: source, to: destination)
    }

    private func deleteSteps(at offsets: IndexSet) {
        for index in offsets {
            let step = viewModel.recipe.steps[index]
            viewModel.removeStep(id: step.id)
        }
    }
}

#Preview {
    StepsView()
        .environment(RecipeViewModel())
}
