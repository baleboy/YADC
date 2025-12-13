//
//  PreFerment.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import Foundation

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

struct PreFerment: Codable, Equatable {
    var type: PreFermentType
    var flourWeight: Double
    var hydration: Double
    var yeastPercentage: Double
    var isEnabled: Bool

    var waterWeight: Double {
        flourWeight * hydration / 100
    }

    var yeastWeight: Double {
        flourWeight * yeastPercentage / 100
    }

    var totalWeight: Double {
        flourWeight + waterWeight + yeastWeight
    }

    /// Calculate flour weight needed to achieve a target total weight
    mutating func setTotalWeight(_ total: Double) {
        // totalWeight = flourWeight * (1 + hydration/100 + yeastPercentage/100)
        // flourWeight = totalWeight / (1 + hydration/100 + yeastPercentage/100)
        let multiplier = 1 + hydration / 100 + yeastPercentage / 100
        flourWeight = total / multiplier
    }

    static let `default` = PreFerment(
        type: .poolish,
        flourWeight: 100,
        hydration: 100,
        yeastPercentage: 0.1,
        isEnabled: false
    )

    mutating func updateType(_ type: PreFermentType) {
        self.type = type
        if type != .custom {
            self.hydration = type.defaultHydration
        }
    }
}
