//
//  Double+Formatting.swift
//  YADC
//
//  Created by Francesco Balestrieri on 7.12.2025.
//

import Foundation

extension Double {
    var formatted0: String {
        String(format: "%.0f", self)
    }

    var formatted1: String {
        String(format: "%.1f", self)
    }

    var formatted2: String {
        String(format: "%.2f", self)
    }

    var percentageFormatted: String {
        String(format: "%.1f%%", self)
    }

    var weightFormatted: String {
        String(format: "%.1f", self)
    }
}
