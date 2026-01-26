//
//  JournalStore.swift
//  YADC
//
//  Created by Francesco Balestrieri on 21.12.2025.
//

import Foundation
import Observation
import UIKit

@Observable
final class JournalStore {
    var entries: [JournalEntry] = []

    private let persistenceService: PersistenceService
    private let imageService = JournalImageService.shared

    init(persistenceService: PersistenceService = .shared) {
        self.persistenceService = persistenceService
        self.entries = persistenceService.loadJournalEntries()
    }

    // MARK: - CRUD Operations

    func addEntry(_ entry: JournalEntry) {
        entries.append(entry)
        saveEntries()
    }

    func updateEntry(_ entry: JournalEntry) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        var updated = entry
        updated.updatedAt = Date()
        entries[index] = updated
        saveEntries()
    }

    func deleteEntry(id: UUID) {
        imageService.deleteAllImages(for: id)
        entries.removeAll { $0.id == id }
        saveEntries()
    }

    func deleteEntries(at offsets: IndexSet) {
        let sortedEntries = self.sortedEntries
        for index in offsets {
            imageService.deleteAllImages(for: sortedEntries[index].id)
        }
        let idsToDelete = offsets.map { sortedEntries[$0].id }
        entries.removeAll { idsToDelete.contains($0.id) }
        saveEntries()
    }

    func entry(withId id: UUID) -> JournalEntry? {
        entries.first { $0.id == id }
    }

    func entries(for recipeId: UUID) -> [JournalEntry] {
        entries.filter { $0.recipeId == recipeId }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func ratingInfo(for recipeId: UUID) -> (average: Double, count: Int)? {
        let recipeEntries = entries.filter { $0.recipeId == recipeId }
        guard !recipeEntries.isEmpty else { return nil }
        let total = recipeEntries.reduce(0) { $0 + $1.rating }
        let average = Double(total) / Double(recipeEntries.count)
        return (average: average, count: recipeEntries.count)
    }

    // MARK: - Image Operations

    func addImage(_ image: UIImage, to entryId: UUID) {
        guard let index = entries.firstIndex(where: { $0.id == entryId }),
              entries[index].photoCount < JournalImageService.maxPhotosPerEntry else { return }

        let photoIndex = entries[index].photoCount
        if imageService.saveImage(image, for: entryId, at: photoIndex) {
            entries[index].photoCount += 1
            entries[index].updatedAt = Date()
            saveEntries()
        }
    }

    func removeImage(from entryId: UUID, at photoIndex: Int) {
        guard let index = entries.firstIndex(where: { $0.id == entryId }) else { return }
        imageService.deleteImage(for: entryId, at: photoIndex, totalCount: entries[index].photoCount)
        entries[index].photoCount -= 1
        entries[index].updatedAt = Date()
        saveEntries()
    }

    func loadImages(for entryId: UUID) -> [UIImage] {
        guard let entry = entry(withId: entryId) else { return [] }
        return imageService.loadImages(for: entryId, count: entry.photoCount)
    }

    func loadThumbnail(for entryId: UUID) -> UIImage? {
        imageService.loadThumbnail(for: entryId)
    }

    // MARK: - Sorted Access

    var sortedEntries: [JournalEntry] {
        entries.sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Private

    private func saveEntries() {
        persistenceService.saveJournalEntries(entries)
    }
}
