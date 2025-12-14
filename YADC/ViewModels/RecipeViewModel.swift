//
//  RecipeViewModel.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class RecipeViewModel {
    var recipe: Recipe
    var mode: CalculatorMode = .forward

    let isNewRecipe: Bool
    private let originalRecipeId: UUID?

    // Reference to store for settings access
    var store: RecipeStore?

    var settings: Settings {
        store?.settings ?? Settings.default
    }

    // MARK: - Initialization

    init(recipe: Recipe? = nil, store: RecipeStore? = nil) {
        if let existingRecipe = recipe {
            self.recipe = existingRecipe
            self.isNewRecipe = false
            self.originalRecipeId = existingRecipe.id
        } else {
            self.recipe = Recipe.default
            self.isNewRecipe = true
            self.originalRecipeId = nil
        }
        self.store = store
        recalculateWeights()
    }

    // MARK: - Save/Discard

    func saveChanges() -> Recipe {
        recipe.updatedAt = Date()
        return recipe
    }

    func discardChanges() {
        // No-op, the editing copy is simply discarded
    }

    // MARK: - Mode Switching

    func switchToForwardMode() {
        mode = .forward
    }

    func switchToReverseMode() {
        mode = .reverse
    }

    // MARK: - Dough Parameters

    func updateNumberOfBalls(_ count: Int) {
        recipe.numberOfBalls = max(1, count)
        if mode == .reverse {
            // In reverse mode, update weight per ball based on usable dough (after residue)
            let usableDough = recipe.totalIngredientWeight * (1 - settings.doughResiduePercentage / 100)
            recipe.weightPerBall = usableDough / Double(recipe.numberOfBalls)
        } else {
            recalculateWeights()
        }
    }

    func updateWeightPerBall(_ weight: Double) {
        recipe.weightPerBall = max(1, weight)
        recalculateWeights()
    }

    // MARK: - Forward Mode Actions

    func updateHydration(_ newHydration: Double) {
        recipe.hydration = max(0, min(200, newHydration))
        if let index = recipe.ingredients.firstIndex(where: { $0.isWater }) {
            recipe.ingredients[index].percentage = recipe.hydration
        }
        recalculateWeights()
    }

    func updateIngredientPercentage(id: UUID, percentage: Double) {
        guard let index = recipe.ingredients.firstIndex(where: { $0.id == id }) else { return }

        let ingredient = recipe.ingredients[index]
        if ingredient.isFlour { return }

        recipe.ingredients[index].percentage = max(0, percentage)

        if ingredient.isWater {
            recipe.hydration = percentage
        }

        recalculateWeights()
    }

    // MARK: - Reverse Mode Actions

    func updateIngredientWeight(id: UUID, weight: Double) {
        guard let index = recipe.ingredients.firstIndex(where: { $0.id == id }) else { return }
        recipe.ingredients[index].weight = max(0, weight)
        recalculateFromWeights()
    }

    // MARK: - Ingredient Management

    func addIngredient(name: String, percentage: Double, hydrationContribution: HydrationContribution = .none) {
        let ingredient = Ingredient(name: name, percentage: percentage, hydrationContribution: hydrationContribution)
        recipe.ingredients.append(ingredient)
        recalculateWeights()
    }

    func addIngredientByWeight(name: String, weight: Double, hydrationContribution: HydrationContribution = .none) {
        let ingredient = Ingredient(name: name, weight: weight, hydrationContribution: hydrationContribution)
        recipe.ingredients.append(ingredient)
        recalculateFromWeights()
    }

    func removeIngredient(id: UUID) {
        guard let ingredient = recipe.ingredients.first(where: { $0.id == id }),
              !ingredient.isCore else { return }
        recipe.ingredients.removeAll { $0.id == id }
        recalculateWeights()
    }

    // MARK: - Pre-ferment Management

    func addPreFerment(type: PreFermentType, totalWeight: Double, yeastPercentage: Double = 0.1) {
        let metadata = PreFermentMetadata(
            type: type,
            hydration: type.defaultHydration,
            yeastPercentage: yeastPercentage
        )

        var preFerment = Ingredient(
            name: type.displayName,
            weight: totalWeight,
            ingredientType: .preFerment,
            preFermentMetadata: metadata
        )

        preFerment.calculateSubIngredients()

        // Calculate percentage based on pre-ferment's total weight relative to total flour
        if mode == .forward {
            let currentTotalFlour = CalculationEngine.calculateTotalFlour(ingredients: recipe.ingredients)
            if currentTotalFlour > 0 {
                preFerment.percentage = (totalWeight / currentTotalFlour) * 100
            }
        }

        recipe.ingredients.append(preFerment)

        if mode == .forward {
            recalculateWeights()
        } else {
            recalculateFromWeights()
        }
    }

    func updatePreFermentWeight(id: UUID, totalWeight: Double) {
        guard let index = recipe.ingredients.firstIndex(where: { $0.id == id && $0.isPreFerment }) else { return }
        recipe.ingredients[index].weight = max(0, totalWeight)
        recipe.ingredients[index].calculateSubIngredients()

        if mode == .forward {
            // Update percentage so pre-ferment scales with recipe
            let currentTotalFlour = CalculationEngine.calculateTotalFlour(ingredients: recipe.ingredients)
            if currentTotalFlour > 0 {
                recipe.ingredients[index].percentage = (totalWeight / currentTotalFlour) * 100
            }
            recalculateWeights()
        } else {
            recalculateFromWeights()
        }
    }

    func updatePreFermentPercentage(id: UUID, percentage: Double) {
        guard let index = recipe.ingredients.firstIndex(where: { $0.id == id && $0.isPreFerment }) else { return }
        recipe.ingredients[index].percentage = max(0, percentage)
        recalculateWeights()
    }

    func updatePreFermentType(id: UUID, type: PreFermentType) {
        guard let index = recipe.ingredients.firstIndex(where: { $0.id == id && $0.isPreFerment }) else { return }

        if var metadata = recipe.ingredients[index].preFermentMetadata {
            metadata.type = type
            if type != .custom {
                metadata.hydration = type.defaultHydration
            }
            recipe.ingredients[index].preFermentMetadata = metadata
            recipe.ingredients[index].name = type.displayName
            recipe.ingredients[index].calculateSubIngredients()
        }

        if mode == .forward {
            recalculateWeights()
        } else {
            recalculateFromWeights()
        }
    }

    func updatePreFermentHydration(id: UUID, hydration: Double) {
        guard let index = recipe.ingredients.firstIndex(where: { $0.id == id && $0.isPreFerment }) else { return }

        if var metadata = recipe.ingredients[index].preFermentMetadata {
            metadata.hydration = max(0, min(200, hydration))
            recipe.ingredients[index].preFermentMetadata = metadata
            recipe.ingredients[index].calculateSubIngredients()
        }

        if mode == .forward {
            recalculateWeights()
        } else {
            recalculateFromWeights()
        }
    }

    func updatePreFermentYeast(id: UUID, yeastPercentage: Double) {
        guard let index = recipe.ingredients.firstIndex(where: { $0.id == id && $0.isPreFerment }) else { return }

        if var metadata = recipe.ingredients[index].preFermentMetadata {
            metadata.yeastPercentage = max(0, min(10, yeastPercentage))
            recipe.ingredients[index].preFermentMetadata = metadata
            recipe.ingredients[index].calculateSubIngredients()
        }

        if mode == .forward {
            recalculateWeights()
        } else {
            recalculateFromWeights()
        }
    }

    // MARK: - Calculations

    private func recalculateWeights() {
        recipe.ingredients = CalculationEngine.calculateWeights(
            recipe: recipe,
            doughResiduePercentage: settings.doughResiduePercentage
        )
    }

    private func recalculateFromWeights() {
        recipe = CalculationEngine.recalculateFromWeights(recipe: recipe)
        // Update weight per ball based on usable dough (after residue)
        if recipe.numberOfBalls > 0 {
            let usableDough = recipe.totalIngredientWeight * (1 - settings.doughResiduePercentage / 100)
            recipe.weightPerBall = usableDough / Double(recipe.numberOfBalls)
        }
    }

    // MARK: - Display Helpers

    func displayWeight(_ weight: Double) -> Double {
        CalculationEngine.convertWeight(weight, to: settings.unitSystem)
    }

    func weightFromInput(_ input: Double) -> Double {
        CalculationEngine.convertToGrams(input, from: settings.unitSystem)
    }

    var weightUnit: String {
        settings.unitSystem.weightUnit
    }

    // MARK: - Step Management

    var timerService: TimerService = .shared

    func addStep(description: String, waitingTimeMinutes: Int?, temperatureCelsius: Double?) {
        let order = recipe.steps.count
        let step = Step(
            description: description,
            waitingTimeMinutes: waitingTimeMinutes,
            temperatureCelsius: temperatureCelsius,
            order: order
        )
        recipe.steps.append(step)
    }

    func updateStep(id: UUID, description: String, waitingTimeMinutes: Int?, temperatureCelsius: Double?) {
        guard let index = recipe.steps.firstIndex(where: { $0.id == id }) else { return }
        recipe.steps[index].description = description
        recipe.steps[index].waitingTimeMinutes = waitingTimeMinutes
        recipe.steps[index].temperatureCelsius = temperatureCelsius
    }

    func removeStep(id: UUID) {
        timerService.stopTimer(for: id)
        recipe.steps.removeAll { $0.id == id }
        reorderSteps()
    }

    func moveStep(from source: IndexSet, to destination: Int) {
        recipe.steps.move(fromOffsets: source, toOffset: destination)
        reorderSteps()
    }

    private func reorderSteps() {
        for index in recipe.steps.indices {
            recipe.steps[index].order = index
        }
    }

    // MARK: - Timer Actions

    func startStepTimer(for step: Step) {
        timerService.requestNotificationPermissions()
        timerService.startTimer(for: step)
    }

    func stopStepTimer(for stepId: UUID) {
        timerService.stopTimer(for: stepId)
    }

    func pauseStepTimer(for stepId: UUID) {
        timerService.pauseTimer(for: stepId)
    }

    func resumeStepTimer(for stepId: UUID) {
        timerService.resumeTimer(for: stepId)
    }

    // MARK: - Temperature Display Helpers

    func displayTemperature(_ celsius: Double) -> Double {
        switch settings.unitSystem {
        case .metric:
            return celsius
        case .imperial:
            return celsius * 9 / 5 + 32
        }
    }

    func temperatureFromInput(_ input: Double) -> Double {
        switch settings.unitSystem {
        case .metric:
            return input
        case .imperial:
            return (input - 32) * 5 / 9
        }
    }

    var temperatureUnit: String {
        settings.unitSystem.temperatureUnit
    }
}
