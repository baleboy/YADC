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

struct Ingredient: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var percentage: Double
    var weight: Double
    var isFlour: Bool
    var isWater: Bool
    var hydrationContribution: HydrationContribution

    init(
        id: UUID = UUID(),
        name: String,
        percentage: Double = 0,
        weight: Double = 0,
        isFlour: Bool = false,
        isWater: Bool = false,
        hydrationContribution: HydrationContribution = .none
    ) {
        self.id = id
        self.name = name
        self.percentage = percentage
        self.weight = weight
        self.isFlour = isFlour
        self.isWater = isWater
        self.hydrationContribution = hydrationContribution
    }

    var isCore: Bool {
        isFlour || isWater
    }
}
