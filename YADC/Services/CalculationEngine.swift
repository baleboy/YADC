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

        // Total percentage = flour (100) + water (hydration) + other ingredients + pre-ferments
        let otherPercentagesSum = recipe.otherIngredients.reduce(0) { $0 + $1.percentage }
        let preFermentPercentagesSum = recipe.ingredients
            .filter { $0.isPreFerment }
            .reduce(0) { $0 + $1.percentage }
        let totalPercentage = 100 + recipe.hydration + otherPercentagesSum + preFermentPercentagesSum

        guard totalPercentage > 0 else { return recipe.ingredients }

        // Total flour weight calculation (includes pre-ferment flour)
        let totalFlourWeight = adjustedWeight * 100 / totalPercentage

        // First pass: calculate pre-ferment weights and their flour/water contributions
        var preFermentFlour: Double = 0
        var preFermentWater: Double = 0

        var updatedIngredients = recipe.ingredients.map { ingredient -> Ingredient in
            var updated = ingredient
            if ingredient.isPreFerment {
                // Scale pre-ferment based on its percentage of total flour
                updated.weight = totalFlourWeight * ingredient.percentage / 100
                updated.calculateSubIngredients()

                if let subIngredients = updated.subIngredients {
                    preFermentFlour += subIngredients.first(where: { $0.isFlour })?.weight ?? 0
                    preFermentWater += subIngredients.first(where: { $0.isWater })?.weight ?? 0
                }
            }
            return updated
        }

        // Main dough flour and water (subtract pre-ferment amounts)
        let mainFlourWeight = max(0, totalFlourWeight - preFermentFlour)
        let totalWaterWeight = totalFlourWeight * recipe.hydration / 100
        let mainWaterWeight = max(0, totalWaterWeight - preFermentWater)

        // Second pass: update non-pre-ferment ingredients
        updatedIngredients = updatedIngredients.map { ingredient in
            var updated = ingredient
            if ingredient.isPreFerment {
                // Already calculated
            } else if ingredient.isFlour {
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

        return updatedIngredients
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

        // Calculate total flour and water using helper methods (includes pre-ferment)
        let totalFlourWeight = calculateTotalFlour(ingredients: recipe.ingredients)
        let totalWaterWeight = calculateTotalWater(ingredients: recipe.ingredients)

        // Calculate overall hydration
        updated.hydration = calculateHydration(flourWeight: totalFlourWeight, waterWeight: totalWaterWeight)

        // Update all percentages based on total flour and recalculate pre-ferment breakdowns
        updated.ingredients = calculatePercentagesWithTotalFlour(
            ingredients: recipe.ingredients,
            totalFlourWeight: totalFlourWeight
        ).map { ingredient in
            if ingredient.isPreFerment {
                return updatePreFermentBreakdown(ingredient: ingredient)
            }
            return ingredient
        }

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

    // MARK: - Pre-ferment Helpers

    /// Calculate total flour weight from all sources including pre-ferment
    static func calculateTotalFlour(ingredients: [Ingredient]) -> Double {
        var totalFlour: Double = 0

        for ingredient in ingredients {
            if ingredient.isPreFerment {
                if let subIngredients = ingredient.subIngredients {
                    totalFlour += subIngredients.first(where: { $0.isFlour })?.weight ?? 0
                }
            } else if ingredient.isFlour {
                totalFlour += ingredient.weight
            } else if ingredient.hydrationContribution == .flour {
                totalFlour += ingredient.weight
            }
        }

        return totalFlour
    }

    /// Calculate total water weight from all sources including pre-ferment
    static func calculateTotalWater(ingredients: [Ingredient]) -> Double {
        var totalWater: Double = 0

        for ingredient in ingredients {
            if ingredient.isPreFerment {
                if let subIngredients = ingredient.subIngredients {
                    totalWater += subIngredients.first(where: { $0.isWater })?.weight ?? 0
                }
            } else if ingredient.isWater {
                totalWater += ingredient.weight
            } else if ingredient.hydrationContribution == .water {
                totalWater += ingredient.weight
            }
        }

        return totalWater
    }

    /// Update pre-ferment breakdown based on total weight and metadata
    static func updatePreFermentBreakdown(ingredient: Ingredient) -> Ingredient {
        var updated = ingredient
        updated.calculateSubIngredients()
        return updated
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
