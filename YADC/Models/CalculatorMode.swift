//
//  CalculatorMode.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import Foundation

enum CalculatorMode: String, Codable, Identifiable {
    case forward
    case reverse

    var id: String { rawValue }
}
