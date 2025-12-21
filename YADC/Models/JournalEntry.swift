//
//  JournalEntry.swift
//  YADC
//
//  Created by Francesco Balestrieri on 21.12.2025.
//

import Foundation

struct JournalEntry: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var recipeId: UUID
    var rating: Int
    var notes: String
    var photoCount: Int
    var createdAt: Date
    var updatedAt: Date

    // Hashable - use id only for navigation purposes
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    init(
        id: UUID = UUID(),
        recipeId: UUID,
        rating: Int = 3,
        notes: String = "",
        photoCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.recipeId = recipeId
        self.rating = max(1, min(5, rating))
        self.notes = notes
        self.photoCount = max(0, min(5, photoCount))
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
