//
//  RecipeViewModel.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import Foundation
import Observation

@Observable
final class RecipeViewModel {
    var recipe: Recipe
    var mode: CalculatorMode = .forward
    var settings: Settings

    private let persistenceService: PersistenceService

    init(persistenceService: PersistenceService = .shared) {
        self.persistenceService = persistenceService
        self.recipe = persistenceService.loadRecipe() ?? Recipe.default
        self.settings = persistenceService.loadSettings() ?? Settings.default

        recalculateWeights()
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
        recalculateWeights()
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

    // MARK: - Pre-ferment

    func togglePreFerment(_ enabled: Bool) {
        recipe.preFerment.isEnabled = enabled
        recalculateWeights()
    }

    func updatePreFermentType(_ type: PreFermentType) {
        recipe.preFerment.updateType(type)
        recalculateWeights()
    }

    func updatePreFermentFlour(_ weight: Double) {
        recipe.preFerment.flourWeight = max(0, weight)
        recalculateWeights()
    }

    func updatePreFermentHydration(_ hydration: Double) {
        recipe.preFerment.hydration = max(0, min(200, hydration))
        recalculateWeights()
    }

    func updatePreFermentYeast(_ percentage: Double) {
        recipe.preFerment.yeastPercentage = max(0, min(10, percentage))
        recalculateWeights()
    }

    // MARK: - Settings

    func updateUnitSystem(_ system: UnitSystem) {
        settings.unitSystem = system
        save()
    }

    func updateDoughResidue(_ percentage: Double) {
        settings.doughResiduePercentage = max(0, min(20, percentage))
        recalculateWeights()
    }

    // MARK: - Calculations

    private func recalculateWeights() {
        recipe.ingredients = CalculationEngine.calculateWeights(
            recipe: recipe,
            doughResiduePercentage: settings.doughResiduePercentage
        )
        save()
    }

    private func recalculateFromWeights() {
        recipe = CalculationEngine.recalculateFromWeights(recipe: recipe)
        save()
    }

    // MARK: - Persistence

    private func save() {
        persistenceService.save(recipe: recipe)
        persistenceService.save(settings: settings)
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
}
