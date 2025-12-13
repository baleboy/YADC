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
    var steps: [Step]

    enum CodingKeys: String, CodingKey {
        case numberOfBalls, weightPerBall, hydration, ingredients, preFerment, steps
    }

    init(
        numberOfBalls: Int,
        weightPerBall: Double,
        hydration: Double,
        ingredients: [Ingredient],
        preFerment: PreFerment,
        steps: [Step] = []
    ) {
        self.numberOfBalls = numberOfBalls
        self.weightPerBall = weightPerBall
        self.hydration = hydration
        self.ingredients = ingredients
        self.preFerment = preFerment
        self.steps = steps
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        numberOfBalls = try container.decode(Int.self, forKey: .numberOfBalls)
        weightPerBall = try container.decode(Double.self, forKey: .weightPerBall)
        hydration = try container.decode(Double.self, forKey: .hydration)
        ingredients = try container.decode([Ingredient].self, forKey: .ingredients)
        preFerment = try container.decode(PreFerment.self, forKey: .preFerment)
        steps = try container.decodeIfPresent([Step].self, forKey: .steps) ?? []
    }

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
        preFerment: PreFerment.default,
        steps: []
    )
}
