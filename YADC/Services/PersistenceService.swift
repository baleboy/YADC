//
//  PersistenceService.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import Foundation

final class PersistenceService {
    static let shared = PersistenceService()

    private let defaults = UserDefaults.standard
    private let legacyRecipeKey = "savedRecipe"
    private let recipesKey = "savedRecipes"
    private let settingsKey = "appSettings"
    private let migrationKey = "didMigrateToMultiRecipe"

    private init() {}

    // MARK: - Migration

    func migrateIfNeeded() {
        guard !defaults.bool(forKey: migrationKey) else { return }

        // Check for legacy single recipe
        if let data = defaults.data(forKey: legacyRecipeKey) {
            // Try to decode as new Recipe format first (with id)
            if let recipe = try? JSONDecoder().decode(Recipe.self, from: data) {
                // Already has the new format, just wrap in array
                saveRecipes([recipe])
            } else {
                // Try to decode legacy format (without id/name) and migrate
                if let legacyRecipe = try? JSONDecoder().decode(LegacyRecipe.self, from: data) {
                    let migratedRecipe = Recipe(
                        name: "My Recipe",
                        numberOfBalls: legacyRecipe.numberOfBalls,
                        weightPerBall: legacyRecipe.weightPerBall,
                        hydration: legacyRecipe.hydration,
                        ingredients: legacyRecipe.ingredients,
                        steps: legacyRecipe.steps
                    )
                    saveRecipes([migratedRecipe])
                }
            }
            // Clean up legacy key
            defaults.removeObject(forKey: legacyRecipeKey)
        }

        defaults.set(true, forKey: migrationKey)
    }

    // MARK: - Recipes (Multiple)

    func saveRecipes(_ recipes: [Recipe]) {
        if let encoded = try? JSONEncoder().encode(recipes) {
            defaults.set(encoded, forKey: recipesKey)
        }
    }

    func loadRecipes() -> [Recipe] {
        guard let data = defaults.data(forKey: recipesKey),
              let recipes = try? JSONDecoder().decode([Recipe].self, from: data) else {
            return []
        }
        return recipes
    }

    // MARK: - Settings

    func save(settings: Settings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            defaults.set(encoded, forKey: settingsKey)
        }
    }

    func loadSettings() -> Settings? {
        guard let data = defaults.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(Settings.self, from: data) else {
            return nil
        }
        return settings
    }

    // MARK: - Reset

    func resetAll() {
        defaults.removeObject(forKey: legacyRecipeKey)
        defaults.removeObject(forKey: recipesKey)
        defaults.removeObject(forKey: settingsKey)
        defaults.removeObject(forKey: migrationKey)
    }
}

// MARK: - Legacy Recipe (for migration)

private struct LegacyRecipe: Codable {
    var numberOfBalls: Int
    var weightPerBall: Double
    var hydration: Double
    var ingredients: [Ingredient]
    var steps: [Step]
}
