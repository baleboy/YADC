//
//  Step.swift
//  YADC
//
//  Created by Claude on 13.12.2025.
//

import Foundation

struct Step: Identifiable, Codable, Equatable {
    let id: UUID
    var description: String
    var waitingTimeMinutes: Int?
    var temperatureCelsius: Double?
    var order: Int

    init(
        id: UUID = UUID(),
        description: String,
        waitingTimeMinutes: Int? = nil,
        temperatureCelsius: Double? = nil,
        order: Int = 0
    ) {
        self.id = id
        self.description = description
        self.waitingTimeMinutes = waitingTimeMinutes
        self.temperatureCelsius = temperatureCelsius
        self.order = order
    }

    var hasTimer: Bool {
        guard let minutes = waitingTimeMinutes else { return false }
        return minutes > 0
    }
}
