//
//  ScaleRecipeSheet.swift
//  YADC
//
//  Created by Claude on 25.1.2026.
//

import SwiftUI

struct ScaleRecipeSheet: View {
    let recipe: Recipe
    @Environment(RecipeStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var numberOfBalls: Int
    @State private var scaleMultiplier: Double = 1.0
    @State private var scalingMode: ScalingMode = .ballCount
    @State private var showingBakeView = false
    @State private var createdSession: BakeSession?

    enum ScalingMode: String, CaseIterable {
        case ballCount = "By Ball Count"
        case multiplier = "By Scale"
    }

    init(recipe: Recipe) {
        self.recipe = recipe
        self._numberOfBalls = State(initialValue: recipe.numberOfBalls)
    }

    private var scaledTotalWeight: Double {
        switch scalingMode {
        case .ballCount:
            return Double(numberOfBalls) * recipe.weightPerBall
        case .multiplier:
            return recipe.totalDoughWeight * scaleMultiplier
        }
    }

    private var scaledIngredients: [Ingredient] {
        switch scalingMode {
        case .ballCount:
            return CalculationEngine.scaleRecipe(
                recipe,
                numberOfBalls: numberOfBalls,
                doughResiduePercentage: store.settings.doughResiduePercentage
            )
        case .multiplier:
            return CalculationEngine.scaleRecipeByMultiplier(
                recipe,
                multiplier: scaleMultiplier,
                doughResiduePercentage: store.settings.doughResiduePercentage
            )
        }
    }

    private var scaledNumberOfBalls: Int {
        switch scalingMode {
        case .ballCount:
            return numberOfBalls
        case .multiplier:
            return Int(round(Double(recipe.numberOfBalls) * scaleMultiplier))
        }
    }

    private var scaledWeightPerBall: Double {
        switch scalingMode {
        case .ballCount:
            return recipe.weightPerBall
        case .multiplier:
            return recipe.weightPerBall * scaleMultiplier
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(recipe.name)
                        .font(.headline)
                }

                Section("Scaling Method") {
                    Picker("Method", selection: $scalingMode) {
                        ForEach(ScalingMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color("FormRowBackground"))
                }

                Section {
                    switch scalingMode {
                    case .ballCount:
                        Stepper("Number of balls: \(numberOfBalls)", value: $numberOfBalls, in: 1...100)
                            .listRowBackground(Color("FormRowBackground"))
                    case .multiplier:
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Scale: \(scaleMultiplier, specifier: "%.1f")x")
                            Slider(value: $scaleMultiplier, in: 0.5...3.0, step: 0.1)
                                .tint(Color("AccentColor"))
                        }
                        .listRowBackground(Color("FormRowBackground"))
                    }
                }

                Section("Result") {
                    HStack {
                        Text("Total weight")
                        Spacer()
                        Text("\(store.displayWeight(scaledTotalWeight).weightFormatted) \(store.weightUnit)")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("AccentColor"))
                    }
                    .listRowBackground(Color("FormRowBackground"))

                    if scalingMode == .multiplier {
                        HStack {
                            Text("Number of balls")
                            Spacer()
                            Text("\(scaledNumberOfBalls)")
                                .foregroundStyle(Color("TextSecondary"))
                        }
                        .listRowBackground(Color("FormRowBackground"))
                    }
                }

                Section {
                    Button {
                        startBake()
                    } label: {
                        HStack {
                            Spacer()
                            Label("Start Baking", systemImage: "flame.fill")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color("AccentColor"))
                    .foregroundStyle(.white)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("CreamBackground"))
            .navigationTitle("Make It")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(item: $createdSession) { session in
                BakeStepView(sessionId: session.id)
            }
        }
    }

    private func startBake() {
        let session = BakeSessionService.shared.startSession(
            recipe: recipe,
            scaledNumberOfBalls: scaledNumberOfBalls,
            scaledWeightPerBall: scaledWeightPerBall,
            scaledIngredients: scaledIngredients
        )
        createdSession = session
    }
}

#Preview {
    ScaleRecipeSheet(recipe: Recipe.default)
        .environment(RecipeStore())
}
