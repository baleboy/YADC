//
//  YADCTests.swift
//  YADCTests
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import Testing
@testable import YADC

struct CalculationEngineTests {

    // MARK: - Forward Calculation Tests

    @Test func forwardCalculation_basicRecipe() {
        let recipe = Recipe(
            numberOfBalls: 4,
            weightPerBall: 250,
            hydration: 65,
            ingredients: [
                Ingredient(name: "Flour", percentage: 100, isFlour: true),
                Ingredient(name: "Water", percentage: 65, isWater: true),
                Ingredient(name: "Salt", percentage: 2.5),
                Ingredient(name: "Yeast", percentage: 0.5)
            ]
        )

        let result = CalculationEngine.calculateWeights(recipe: recipe)

        // Total = 1000g, total% = 100 + 65 + 2.5 + 0.5 = 168%
        // Flour = 1000 * 100 / 168 ≈ 595.24g
        let flour = result.first { $0.isFlour }!
        #expect(flour.weight > 594 && flour.weight < 596)

        // Water = flour * 65% ≈ 386.9g
        let water = result.first { $0.isWater }!
        #expect(water.weight > 386 && water.weight < 388)

        // Salt = flour * 2.5% ≈ 14.88g
        let salt = result.first { $0.name == "Salt" }!
        #expect(salt.weight > 14 && salt.weight < 16)
    }

    @Test func forwardCalculation_withResidue() {
        let recipe = Recipe(
            numberOfBalls: 4,
            weightPerBall: 250,
            hydration: 65,
            ingredients: [
                Ingredient(name: "Flour", percentage: 100, isFlour: true),
                Ingredient(name: "Water", percentage: 65, isWater: true)
            ]
        )

        let result = CalculationEngine.calculateWeights(recipe: recipe, doughResiduePercentage: 5)

        // Adjusted weight = 1000 * 1.05 = 1050g
        // Total% = 165
        // Flour = 1050 * 100 / 165 ≈ 636.36g
        let flour = result.first { $0.isFlour }!
        #expect(flour.weight > 635 && flour.weight < 638)
    }

    @Test func forwardCalculation_highHydration() {
        let recipe = Recipe(
            numberOfBalls: 2,
            weightPerBall: 500,
            hydration: 80,
            ingredients: [
                Ingredient(name: "Flour", percentage: 100, isFlour: true),
                Ingredient(name: "Water", percentage: 80, isWater: true),
                Ingredient(name: "Salt", percentage: 2)
            ]
        )

        let result = CalculationEngine.calculateWeights(recipe: recipe)

        // Total = 1000g, total% = 182
        // Flour ≈ 549.45g, Water ≈ 439.56g
        let flour = result.first { $0.isFlour }!
        let water = result.first { $0.isWater }!

        #expect(flour.weight > 548 && flour.weight < 551)
        #expect(water.weight > 438 && water.weight < 441)
    }

    @Test func forwardCalculation_withPreFerment() {
        // Create a poolish pre-ferment with 100g flour, 100g water
        let metadata = PreFermentMetadata(type: .poolish, hydration: 100, yeastPercentage: 0.1)
        var poolish = Ingredient(
            name: "Poolish",
            weight: 200.1, // flour + water + yeast
            ingredientType: .preFerment,
            preFermentMetadata: metadata
        )
        poolish.calculateSubIngredients()

        let recipe = Recipe(
            numberOfBalls: 4,
            weightPerBall: 250,
            hydration: 65,
            ingredients: [
                Ingredient(name: "Flour", percentage: 100, isFlour: true),
                Ingredient(name: "Water", percentage: 65, isWater: true),
                Ingredient(name: "Salt", percentage: 2.5),
                poolish
            ]
        )

        let result = CalculationEngine.calculateWeights(recipe: recipe)

        // Pre-ferment: 100g flour, 100g water
        // Total flour needed ≈ 597g, main dough flour = 597 - 100 = 497g
        // Total water needed ≈ 388g, main dough water = 388 - 100 = 288g
        let flour = result.first { $0.isFlour }!
        let water = result.first { $0.isWater }!

        #expect(flour.weight > 490 && flour.weight < 500)
        #expect(water.weight > 280 && water.weight < 295)
    }

    // MARK: - Reverse Calculation Tests

    @Test func reverseCalculation_hydration() {
        let hydration = CalculationEngine.calculateHydration(flourWeight: 600, waterWeight: 390)
        #expect(hydration == 65.0)
    }

    @Test func reverseCalculation_highHydration() {
        let hydration = CalculationEngine.calculateHydration(flourWeight: 500, waterWeight: 400)
        #expect(hydration == 80.0)
    }

    @Test func reverseCalculation_zeroFlour() {
        let hydration = CalculationEngine.calculateHydration(flourWeight: 0, waterWeight: 100)
        #expect(hydration == 0)
    }

    @Test func reverseCalculation_percentages() {
        let ingredients = [
            Ingredient(name: "Flour", weight: 600, isFlour: true),
            Ingredient(name: "Water", weight: 390, isWater: true),
            Ingredient(name: "Salt", weight: 15),
            Ingredient(name: "Yeast", weight: 3)
        ]

        let result = CalculationEngine.calculatePercentages(ingredients: ingredients)

        let flour = result.first { $0.isFlour }!
        #expect(flour.percentage == 100)

        let water = result.first { $0.isWater }!
        #expect(water.percentage == 65.0)

        let salt = result.first { $0.name == "Salt" }!
        #expect(salt.percentage == 2.5)

        let yeast = result.first { $0.name == "Yeast" }!
        #expect(yeast.percentage == 0.5)
    }

    @Test func recalculateFromWeights_fullRecipe() {
        var recipe = Recipe(
            numberOfBalls: 4,
            weightPerBall: 250,
            hydration: 0,
            ingredients: [
                Ingredient(name: "Flour", percentage: 0, weight: 600, isFlour: true),
                Ingredient(name: "Water", percentage: 0, weight: 390, isWater: true),
                Ingredient(name: "Salt", percentage: 0, weight: 15)
            ]
        )

        recipe = CalculationEngine.recalculateFromWeights(recipe: recipe)

        #expect(recipe.hydration == 65.0)
        #expect(recipe.ingredients.first { $0.isFlour }?.percentage == 100)
        #expect(recipe.ingredients.first { $0.isWater }?.percentage == 65.0)
        #expect(recipe.ingredients.first { $0.name == "Salt" }?.percentage == 2.5)
    }

    @Test func recalculateFromWeights_withPreFerment() {
        // Create a poolish pre-ferment with 100g flour, 100g water
        let metadata = PreFermentMetadata(type: .poolish, hydration: 100, yeastPercentage: 0.1)
        var poolish = Ingredient(
            name: "Poolish",
            weight: 200.1,
            ingredientType: .preFerment,
            preFermentMetadata: metadata
        )
        poolish.calculateSubIngredients()

        var recipe = Recipe(
            numberOfBalls: 4,
            weightPerBall: 250,
            hydration: 0,
            ingredients: [
                Ingredient(name: "Flour", percentage: 0, weight: 500, isFlour: true),
                Ingredient(name: "Water", percentage: 0, weight: 290, isWater: true),
                poolish
            ]
        )

        recipe = CalculationEngine.recalculateFromWeights(recipe: recipe)

        // Total flour: 500 + 100 = 600g
        // Total water: 290 + 100 = 390g
        // Hydration: 390/600 * 100 = 65%
        #expect(recipe.hydration == 65.0)
    }

    // MARK: - Unit Conversion Tests

    @Test func unitConversion_gramsToOunces() {
        let ounces = CalculationEngine.gramsToOunces(28.3495)
        #expect(abs(ounces - 1.0) < 0.001)
    }

    @Test func unitConversion_ouncesToGrams() {
        let grams = CalculationEngine.ouncesToGrams(1)
        #expect(abs(grams - 28.3495) < 0.001)
    }

    @Test func unitConversion_roundTrip() {
        let original = 500.0
        let converted = CalculationEngine.ouncesToGrams(CalculationEngine.gramsToOunces(original))
        #expect(abs(converted - original) < 0.001)
    }

    // MARK: - Pre-ferment Tests

    @Test func preFerment_poolishCalculation() {
        let metadata = PreFermentMetadata(type: .poolish, hydration: 100, yeastPercentage: 0.1)
        var poolish = Ingredient(
            name: "Poolish",
            weight: 200.1,
            ingredientType: .preFerment,
            preFermentMetadata: metadata
        )
        poolish.calculateSubIngredients()

        let flour = poolish.subIngredients?.first { $0.isFlour }
        let water = poolish.subIngredients?.first { $0.isWater }

        #expect(flour?.weight ?? 0 > 99 && flour?.weight ?? 0 < 101)
        #expect(water?.weight ?? 0 > 99 && water?.weight ?? 0 < 101)
    }

    @Test func preFerment_bigaDefaults() {
        let bigaType = PreFermentType.biga
        #expect(bigaType.defaultHydration == 55.0)
    }

    @Test func preFerment_subIngredientCalculation() {
        let metadata = PreFermentMetadata(type: .custom, hydration: 75, yeastPercentage: 0.2)
        var preFerment = Ingredient(
            name: "Custom",
            weight: 175.2, // Should calculate to ~100g flour, 75g water, 0.2g yeast
            ingredientType: .preFerment,
            preFermentMetadata: metadata
        )
        preFerment.calculateSubIngredients()

        let flour = preFerment.subIngredients?.first { $0.isFlour }
        let water = preFerment.subIngredients?.first { $0.isWater }
        let yeast = preFerment.subIngredients?.first { !$0.isFlour && !$0.isWater }

        #expect(flour?.weight ?? 0 > 99 && flour?.weight ?? 0 < 101)
        #expect(water?.weight ?? 0 > 74 && water?.weight ?? 0 < 76)
        #expect(yeast?.weight ?? 0 > 0.19 && yeast?.weight ?? 0 < 0.21)
    }
}
