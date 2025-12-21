//
//  JournalEntryEditorView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 21.12.2025.
//

import SwiftUI

struct JournalEntryEditorView: View {
    @Environment(JournalStore.self) private var journalStore
    @Environment(RecipeStore.self) private var recipeStore
    @Environment(\.dismiss) private var dismiss

    let recipeId: UUID
    let existingEntry: JournalEntry?

    @State private var rating: Int
    @State private var notes: String
    @State private var images: [UIImage]

    private var isEditing: Bool {
        existingEntry != nil
    }

    private var recipeName: String {
        recipeStore.recipe(withId: recipeId)?.name ?? "Recipe"
    }

    init(recipeId: UUID, existingEntry: JournalEntry? = nil) {
        self.recipeId = recipeId
        self.existingEntry = existingEntry

        if let entry = existingEntry {
            _rating = State(initialValue: entry.rating)
            _notes = State(initialValue: entry.notes)
            _images = State(initialValue: [])
        } else {
            _rating = State(initialValue: 3)
            _notes = State(initialValue: "")
            _images = State(initialValue: [])
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Recipe")
                        Spacer()
                        Text(recipeName)
                            .foregroundStyle(Color("TextSecondary"))
                    }
                    .listRowBackground(Color("FormRowBackground"))
                }

                Section("Rating") {
                    HStack {
                        Spacer()
                        StarRatingView(rating: $rating)
                            .font(.title)
                        Spacer()
                    }
                    .listRowBackground(Color("FormRowBackground"))
                }

                Section("Photos") {
                    JournalPhotoGridView(images: $images, maxPhotos: JournalImageService.maxPhotosPerEntry)
                        .listRowBackground(Color("FormRowBackground"))
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 150)
                        .listRowBackground(Color("FormRowBackground"))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("CreamBackground"))
            .foregroundStyle(Color("TextPrimary"))
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("CreamBackground"), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadExistingImages()
            }
        }
    }

    private func loadExistingImages() {
        if let entry = existingEntry {
            images = journalStore.loadImages(for: entry.id)
        }
    }

    private func saveEntry() {
        if let existingEntry = existingEntry {
            // Update existing entry
            var updated = existingEntry
            updated.rating = rating
            updated.notes = notes

            // Handle image changes - remove all old images
            let currentCount = existingEntry.photoCount
            for _ in 0..<currentCount {
                journalStore.removeImage(from: existingEntry.id, at: 0)
            }

            // Reload the entry to get the updated photoCount (now 0)
            var entryToUpdate = journalStore.entry(withId: existingEntry.id) ?? updated
            entryToUpdate.rating = rating
            entryToUpdate.notes = notes
            journalStore.updateEntry(entryToUpdate)

            // Add new images
            for image in images {
                journalStore.addImage(image, to: existingEntry.id)
            }

            // Update rating and notes again
            if var finalEntry = journalStore.entry(withId: existingEntry.id) {
                finalEntry.rating = rating
                finalEntry.notes = notes
                journalStore.updateEntry(finalEntry)
            }
        } else {
            // Create new entry
            let newEntry = JournalEntry(recipeId: recipeId, rating: rating, notes: notes)
            journalStore.addEntry(newEntry)

            // Add images
            for image in images {
                journalStore.addImage(image, to: newEntry.id)
            }
        }
    }
}

#Preview {
    JournalEntryEditorView(recipeId: UUID())
        .environment(JournalStore())
        .environment(RecipeStore())
}
