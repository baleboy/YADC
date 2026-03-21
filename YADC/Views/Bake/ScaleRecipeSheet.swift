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
            ScrollView {
                VStack(spacing: 24) {
                    // Recipe name
                    Text(recipe.name)
                        .font(AppFont.serifHeadline(24))
                        .foregroundStyle(Color("TextPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Scaling method picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text("SCALING METHOD")
                            .sectionLabel()

                        Picker("Method", selection: $scalingMode) {
                            ForEach(ScalingMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Controls
                    VStack(spacing: 0) {
                        switch scalingMode {
                        case .ballCount:
                            ThemedStepper("Dough Balls", value: $numberOfBalls, in: 1...100)
                                .padding(16)
                        case .multiplier:
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Scale Factor")
                                        .foregroundStyle(Color("TextPrimary"))
                                    Spacer()
                                    Text("\(scaleMultiplier, specifier: "%.1f")x")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(Color("AccentColor"))
                                }
                                Slider(value: $scaleMultiplier, in: 0.5...3.0, step: 0.1)
                                    .tint(Color("AccentColor"))
                            }
                            .padding(16)
                        }
                    }
                    .background(Color("FormRowBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))

                    // Result
                    VStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text("TOTAL DOUGH WEIGHT")
                                .font(.system(size: 10, weight: .semibold))
                                .tracking(1.2)
                                .foregroundStyle(.white.opacity(0.8))
                            Text("\(store.displayWeight(scaledTotalWeight).weightFormatted)\(store.weightUnit)")
                                .font(AppFont.serifDisplay(36))
                                .foregroundStyle(.white)

                            if scalingMode == .multiplier {
                                Text("\(scaledNumberOfBalls) balls")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(
                            LinearGradient(
                                colors: [Color("AccentColor"), Color("PrimaryContainer")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))
                    }

                    // Start button
                    Button {
                        startBake()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "flame.fill")
                            Text("Start Baking")
                                .fontWeight(.semibold)
                        }
                    }
                    .buttonStyle(GradientPrimaryButtonStyle())
                }
                .padding(20)
            }
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
