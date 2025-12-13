//
//  Settings.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import Foundation

enum UnitSystem: String, Codable, CaseIterable {
    case metric
    case imperial

    var weightUnit: String {
        switch self {
        case .metric: return "g"
        case .imperial: return "oz"
        }
    }

    var temperatureUnit: String {
        switch self {
        case .metric: return "°C"
        case .imperial: return "°F"
        }
    }
}

struct Settings: Codable, Equatable {
    var unitSystem: UnitSystem
    var doughResiduePercentage: Double

    static let `default` = Settings(
        unitSystem: .metric,
        doughResiduePercentage: 2.0
    )
}
