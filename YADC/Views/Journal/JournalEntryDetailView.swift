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
        ScrollView {
            VStack(spacing: 24) {
                // Photo gallery
                if !images.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(Array(images.enumerated()), id: \.offset) { _, image in
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 280, height: 210)
                                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                VStack(spacing: 20) {
                    // Date
                    Text(formattedDate.uppercased())
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(1.2)
                        .foregroundStyle(Color("AccentColor"))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Recipe name
                    Text(recipeName)
                        .font(AppFont.serifHeadline(28))
                        .foregroundStyle(Color("TextPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Rating
                    HStack {
                        Text("Rating")
                            .foregroundStyle(Color("TextSecondary"))
                        Spacer()
                        StarRatingDisplayView(rating: currentEntry.rating)
                    }
                    .padding(16)
                    .background(Color("FormRowBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))

                    // Notes
                    if !currentEntry.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NOTES")
                                .sectionLabel()

                            Text(currentEntry.notes)
                                .font(AppFont.serifItalic(16))
                                .foregroundStyle(Color("TextPrimary"))
                                .lineSpacing(6)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color("TertiaryFixed").opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(Color("CreamBackground"))
        .foregroundStyle(Color("TextPrimary"))
        .navigationTitle("Journal Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEditor = true
                } label: {
                    Text("EDIT")
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(0.8)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color("AccentColor"))
                        .clipShape(Capsule())
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
