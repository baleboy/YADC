//
//  RecipeStore.swift
//  YADC
//
//  Created by Francesco Balestrieri on 14.12.2025.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class RecipeStore {
    var recipes: [Recipe] = []
    var settings: Settings

    private let persistenceService: PersistenceService

    init(persistenceService: PersistenceService = .shared) {
        self.persistenceService = persistenceService

        // Run migration for legacy single-recipe data
        persistenceService.migrateIfNeeded()

        // Load data
        self.recipes = persistenceService.loadRecipes()
        self.settings = persistenceService.loadSettings() ?? Settings.default

        // Calculate weights for all recipes on load
        recalculateAllRecipes()
    }

    // MARK: - Recipe CRUD

    func addRecipe(_ recipe: Recipe) {
        var newRecipe = recipe
        newRecipe = recalculateRecipe(newRecipe)
        recipes.append(newRecipe)
        saveRecipes()
    }

    func updateRecipe(_ recipe: Recipe) {
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        var updatedRecipe = recipe
        updatedRecipe = recalculateRecipe(updatedRecipe)
        recipes[index] = updatedRecipe
        saveRecipes()
    }

    func deleteRecipe(id: UUID) {
        recipes.removeAll { $0.id == id }
        saveRecipes()
    }

    func deleteRecipes(at offsets: IndexSet) {
        recipes.remove(atOffsets: offsets)
        saveRecipes()
    }

    func recipe(withId id: UUID) -> Recipe? {
        recipes.first { $0.id == id }
    }

    // MARK: - Quick Actions (for detail view)

    func updateNumberOfBalls(for recipeId: UUID, count: Int) {
        guard let index = recipes.firstIndex(where: { $0.id == recipeId }) else { return }
        recipes[index].numberOfBalls = max(1, count)
        recipes[index] = recalculateRecipe(recipes[index])
        saveRecipes()
    }

    // MARK: - Settings

    func updateUnitSystem(_ system: UnitSystem) {
        settings.unitSystem = system
        saveSettings()
    }

    func updateDoughResidue(_ percentage: Double) {
        settings.doughResiduePercentage = max(0, min(20, percentage))
        recalculateAllRecipes()
        saveRecipes()
        saveSettings()
    }

    func resetToDefaults() {
        recipes = []
        settings = Settings.default
        saveRecipes()
        saveSettings()
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

    // MARK: - Private Helpers

    private func recalculateRecipe(_ recipe: Recipe) -> Recipe {
        var updated = recipe
        updated.ingredients = CalculationEngine.calculateWeights(
            recipe: updated,
            doughResiduePercentage: settings.doughResiduePercentage
        )
        return updated
    }

    private func recalculateAllRecipes() {
        recipes = recipes.map { recalculateRecipe($0) }
    }

    private func saveRecipes() {
        persistenceService.saveRecipes(recipes)
    }

    private func saveSettings() {
        persistenceService.save(settings: settings)
    }
}
