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
    private let recipeKey = "savedRecipe"
    private let settingsKey = "appSettings"

    private init() {}

    // MARK: - Recipe

    func save(recipe: Recipe) {
        if let encoded = try? JSONEncoder().encode(recipe) {
            defaults.set(encoded, forKey: recipeKey)
        }
    }

    func loadRecipe() -> Recipe? {
        guard let data = defaults.data(forKey: recipeKey),
              let recipe = try? JSONDecoder().decode(Recipe.self, from: data) else {
            return nil
        }
        return recipe
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
        defaults.removeObject(forKey: recipeKey)
        defaults.removeObject(forKey: settingsKey)
    }
}
