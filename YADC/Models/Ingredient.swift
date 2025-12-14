//
//  Ingredient.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import Foundation

enum HydrationContribution: String, Codable, CaseIterable, Identifiable {
    case none
    case flour
    case water

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "Other"
        case .flour: return "Flour"
        case .water: return "Water"
        }
    }
}

enum IngredientType: String, Codable {
    case regular
    case preFerment
}

enum PreFermentType: String, Codable, CaseIterable, Identifiable {
    case poolish
    case biga
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .poolish: return "Poolish"
        case .biga: return "Biga"
        case .custom: return "Custom"
        }
    }

    var defaultHydration: Double {
        switch self {
        case .poolish: return 100.0
        case .biga: return 55.0
        case .custom: return 75.0
        }
    }

    var description: String {
        switch self {
        case .poolish: return "100% hydration, equal parts flour and water"
        case .biga: return "55% hydration, stiffer pre-ferment"
        case .custom: return "Custom hydration level"
        }
    }
}

struct PreFermentMetadata: Codable, Equatable {
    var type: PreFermentType
    var hydration: Double
    var yeastPercentage: Double

    var flourRatio: Double { 1.0 }
    var waterRatio: Double { hydration / 100.0 }
    var yeastRatio: Double { yeastPercentage / 100.0 }
    var totalRatio: Double { 1.0 + waterRatio + yeastRatio }
}

struct SubIngredient: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var weight: Double
    var isFlour: Bool
    var isWater: Bool

    init(
        id: UUID = UUID(),
        name: String,
        weight: Double,
        isFlour: Bool = false,
        isWater: Bool = false
    ) {
        self.id = id
        self.name = name
        self.weight = weight
        self.isFlour = isFlour
        self.isWater = isWater
    }
}

struct Ingredient: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var percentage: Double
    var weight: Double
    var isFlour: Bool
    var isWater: Bool
    var hydrationContribution: HydrationContribution
    var ingredientType: IngredientType
    var preFermentMetadata: PreFermentMetadata?
    var subIngredients: [SubIngredient]?

    init(
        id: UUID = UUID(),
        name: String,
        percentage: Double = 0,
        weight: Double = 0,
        isFlour: Bool = false,
        isWater: Bool = false,
        hydrationContribution: HydrationContribution = .none,
        ingredientType: IngredientType = .regular,
        preFermentMetadata: PreFermentMetadata? = nil,
        subIngredients: [SubIngredient]? = nil
    ) {
        self.id = id
        self.name = name
        self.percentage = percentage
        self.weight = weight
        self.isFlour = isFlour
        self.isWater = isWater
        self.hydrationContribution = hydrationContribution
        self.ingredientType = ingredientType
        self.preFermentMetadata = preFermentMetadata
        self.subIngredients = subIngredients
    }

    var isCore: Bool {
        isFlour || isWater
    }

    var isPreFerment: Bool {
        ingredientType == .preFerment
    }

    mutating func calculateSubIngredients() {
        guard let metadata = preFermentMetadata, isPreFerment else {
            subIngredients = nil
            return
        }

        let flourWeight = weight / metadata.totalRatio
        let waterWeight = flourWeight * metadata.waterRatio
        let yeastWeight = flourWeight * metadata.yeastRatio

        subIngredients = [
            SubIngredient(name: "Flour", weight: flourWeight, isFlour: true, isWater: false),
            SubIngredient(name: "Water", weight: waterWeight, isFlour: false, isWater: true),
            SubIngredient(name: "Yeast", weight: yeastWeight, isFlour: false, isWater: false)
        ]
    }
}
