//
//  CalculationEngine.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import Foundation

struct CalculationEngine {

    // MARK: - Forward Calculation (percentages -> weights)

    /// Calculate ingredient weights from percentages and target dough weight
    static func calculateWeights(
        recipe: Recipe,
        doughResiduePercentage: Double = 0
    ) -> [Ingredient] {
        let adjustedWeight = recipe.totalDoughWeight * (1 + doughResiduePercentage / 100)

        // Total percentage = flour (100) + water (hydration) + other ingredients
        let otherPercentagesSum = recipe.otherIngredients.reduce(0) { $0 + $1.percentage }
        let totalPercentage = 100 + recipe.hydration + otherPercentagesSum

        guard totalPercentage > 0 else { return recipe.ingredients }

        // Total flour weight calculation (includes pre-ferment flour)
        let totalFlourWeight = adjustedWeight * 100 / totalPercentage

        // Account for pre-ferment contributions
        let preFermentFlour = recipe.preFerment.isEnabled ? recipe.preFerment.flourWeight : 0
        let preFermentWater = recipe.preFerment.isEnabled ? recipe.preFerment.waterWeight : 0

        // Main dough flour and water (subtract pre-ferment amounts)
        let mainFlourWeight = max(0, totalFlourWeight - preFermentFlour)
        let totalWaterWeight = totalFlourWeight * recipe.hydration / 100
        let mainWaterWeight = max(0, totalWaterWeight - preFermentWater)

        return recipe.ingredients.map { ingredient in
            var updated = ingredient
            if ingredient.isFlour {
                updated.weight = mainFlourWeight
                updated.percentage = 100
            } else if ingredient.isWater {
                updated.weight = mainWaterWeight
                updated.percentage = recipe.hydration
            } else {
                updated.weight = totalFlourWeight * ingredient.percentage / 100
            }
            return updated
        }
    }

    // MARK: - Reverse Calculation (weights -> hydration)

    /// Calculate hydration from flour and water weights
    static func calculateHydration(flourWeight: Double, waterWeight: Double) -> Double {
        guard flourWeight > 0 else { return 0 }
        return (waterWeight / flourWeight) * 100
    }

    /// Calculate all percentages from ingredient weights
    static func calculatePercentages(ingredients: [Ingredient]) -> [Ingredient] {
        guard let flour = ingredients.first(where: { $0.isFlour }),
              flour.weight > 0 else {
            return ingredients
        }

        let flourWeight = flour.weight

        return ingredients.map { ingredient in
            var updated = ingredient
            if ingredient.isFlour {
                updated.percentage = 100
            } else {
                updated.percentage = (ingredient.weight / flourWeight) * 100
            }
            return updated
        }
    }

    /// Update recipe with new hydration calculated from ingredient weights
    static func recalculateFromWeights(recipe: Recipe) -> Recipe {
        var updated = recipe

        // Get flour and water weights from main dough
        let mainFlourWeight = recipe.flour?.weight ?? 0
        let mainWaterWeight = recipe.water?.weight ?? 0

        // Add pre-ferment contributions for total hydration calculation
        let preFermentFlour = recipe.preFerment.isEnabled ? recipe.preFerment.flourWeight : 0
        let preFermentWater = recipe.preFerment.isEnabled ? recipe.preFerment.waterWeight : 0

        // Add contributions from other ingredients
        let contributingFlourWeight = recipe.otherIngredients
            .filter { $0.hydrationContribution == .flour }
            .reduce(0) { $0 + $1.weight }
        let contributingWaterWeight = recipe.otherIngredients
            .filter { $0.hydrationContribution == .water }
            .reduce(0) { $0 + $1.weight }

        let totalFlourWeight = mainFlourWeight + preFermentFlour + contributingFlourWeight
        let totalWaterWeight = mainWaterWeight + preFermentWater + contributingWaterWeight

        // Calculate overall hydration
        updated.hydration = calculateHydration(flourWeight: totalFlourWeight, waterWeight: totalWaterWeight)

        // Update all percentages based on total flour
        updated.ingredients = calculatePercentagesWithTotalFlour(
            ingredients: recipe.ingredients,
            totalFlourWeight: totalFlourWeight
        )

        return updated
    }

    /// Calculate percentages using total flour weight (including pre-ferment)
    static func calculatePercentagesWithTotalFlour(
        ingredients: [Ingredient],
        totalFlourWeight: Double
    ) -> [Ingredient] {
        guard totalFlourWeight > 0 else { return ingredients }

        return ingredients.map { ingredient in
            var updated = ingredient
            if ingredient.isFlour {
                updated.percentage = 100
            } else {
                updated.percentage = (ingredient.weight / totalFlourWeight) * 100
            }
            return updated
        }
    }

    // MARK: - Unit Conversion

    static func gramsToOunces(_ grams: Double) -> Double {
        grams / 28.3495
    }

    static func ouncesToGrams(_ ounces: Double) -> Double {
        ounces * 28.3495
    }

    static func convertWeight(_ weight: Double, to unitSystem: UnitSystem) -> Double {
        switch unitSystem {
        case .metric:
            return weight
        case .imperial:
            return gramsToOunces(weight)
        }
    }

    static func convertToGrams(_ weight: Double, from unitSystem: UnitSystem) -> Double {
        switch unitSystem {
        case .metric:
            return weight
        case .imperial:
            return ouncesToGrams(weight)
        }
    }
}
