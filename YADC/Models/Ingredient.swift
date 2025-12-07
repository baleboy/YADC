//
//  Ingredient.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import Foundation

struct Ingredient: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var percentage: Double
    var weight: Double
    var isFlour: Bool
    var isWater: Bool

    init(
        id: UUID = UUID(),
        name: String,
        percentage: Double = 0,
        weight: Double = 0,
        isFlour: Bool = false,
        isWater: Bool = false
    ) {
        self.id = id
        self.name = name
        self.percentage = percentage
        self.weight = weight
        self.isFlour = isFlour
        self.isWater = isWater
    }

    var isCore: Bool {
        isFlour || isWater
    }
}
