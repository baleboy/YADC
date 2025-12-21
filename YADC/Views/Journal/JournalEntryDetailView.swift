//
//  JournalEntryDetailView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 21.12.2025.
//

import SwiftUI

struct JournalEntryDetailView: View {
    let entry: JournalEntry
    @Environment(JournalStore.self) private var journalStore
    @Environment(RecipeStore.self) private var recipeStore
    @Environment(\.dismiss) private var dismiss

    @State private var showingEditor = false
    @State private var images: [UIImage] = []

    private var currentEntry: JournalEntry {
        journalStore.entry(withId: entry.id) ?? entry
    }

    private var recipeName: String {
        recipeStore.recipe(withId: currentEntry.recipeId)?.name ?? "Deleted Recipe"
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: currentEntry.createdAt)
    }

    var body: some View {
        List {
            if !images.isEmpty {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(images.enumerated()), id: \.offset) { _, image in
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 250, height: 200)
                                    .clipped()
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section {
                HStack {
                    Text("Recipe")
                    Spacer()
                    Text(recipeName)
                        .foregroundStyle(Color("TextSecondary"))
                }
                .listRowBackground(Color("FormRowBackground"))

                HStack {
                    Text("Date")
                    Spacer()
                    Text(formattedDate)
                        .foregroundStyle(Color("TextSecondary"))
                }
                .listRowBackground(Color("FormRowBackground"))

                HStack {
                    Text("Rating")
                    Spacer()
                    StarRatingDisplayView(rating: currentEntry.rating)
                }
                .listRowBackground(Color("FormRowBackground"))
            }

            if !currentEntry.notes.isEmpty {
                Section("Notes") {
                    Text(currentEntry.notes)
                        .listRowBackground(Color("FormRowBackground"))
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color("CreamBackground"))
        .foregroundStyle(Color("TextPrimary"))
        .navigationTitle("Journal Entry")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color("CreamBackground"), for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEditor = true
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            JournalEntryEditorView(recipeId: currentEntry.recipeId, existingEntry: currentEntry)
        }
        .onAppear {
            loadImages()
        }
        .onChange(of: showingEditor) { _, isShowing in
            if !isShowing {
                loadImages()
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }

    private func loadImages() {
        images = journalStore.loadImages(for: currentEntry.id)
    }
}

#Preview {
    NavigationStack {
        JournalEntryDetailView(entry: JournalEntry(recipeId: UUID(), rating: 4, notes: "This was a great bake!"))
    }
    .environment(JournalStore())
    .environment(RecipeStore())
}
