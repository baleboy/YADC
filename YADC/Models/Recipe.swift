//
//  Recipe.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import Foundation

struct Recipe: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var numberOfBalls: Int
    var weightPerBall: Double
    var hydration: Double
    var ingredients: [Ingredient]
    var steps: [Step]
    var createdAt: Date
    var updatedAt: Date

    // Hashable - use id only for navigation purposes
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    init(
        id: UUID = UUID(),
        name: String = "New Recipe",
        numberOfBalls: Int,
        weightPerBall: Double,
        hydration: Double,
        ingredients: [Ingredient],
        steps: [Step] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.numberOfBalls = numberOfBalls
        self.weightPerBall = weightPerBall
        self.hydration = hydration
        self.ingredients = ingredients
        self.steps = steps
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var totalDoughWeight: Double {
        Double(numberOfBalls) * weightPerBall
    }

    /// Total weight calculated from ingredient weights (for reverse mode)
    var totalIngredientWeight: Double {
        ingredients.reduce(0) { $0 + $1.weight }
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
        name: "Pizza Dough",
        numberOfBalls: 4,
        weightPerBall: 250,
        hydration: 65,
        ingredients: [
            Ingredient(name: "Flour", percentage: 100, isFlour: true),
            Ingredient(name: "Water", percentage: 65, isWater: true),
            Ingredient(name: "Salt", percentage: 2.5),
            Ingredient(name: "Yeast", percentage: 0.5)
        ],
        steps: []
    )
}
