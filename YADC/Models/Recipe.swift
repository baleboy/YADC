//
//  Recipe.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import Foundation

struct Recipe: Codable, Equatable {
    var numberOfBalls: Int
    var weightPerBall: Double
    var hydration: Double
    var ingredients: [Ingredient]
    var preFerment: PreFerment

    var totalDoughWeight: Double {
        Double(numberOfBalls) * weightPerBall
    }

    var flour: Ingredient? {
        ingredients.first { $0.isFlour }
    }

    var water: Ingredient? {
        ingredients.first { $0.isWater }
    }

    var otherIngredients: [Ingredient] {
        ingredients.filter { !$0.isFlour && !$0.isWater }
    }

    static let `default` = Recipe(
        numberOfBalls: 4,
        weightPerBall: 250,
        hydration: 65,
        ingredients: [
            Ingredient(name: "Flour", percentage: 100, isFlour: true),
            Ingredient(name: "Water", percentage: 65, isWater: true),
            Ingredient(name: "Salt", percentage: 2.5),
            Ingredient(name: "Yeast", percentage: 0.5)
        ],
        preFerment: PreFerment.default
    )
}
