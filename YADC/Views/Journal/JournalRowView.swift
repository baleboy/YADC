//
//  JournalRowView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 21.12.2025.
//

import SwiftUI

struct JournalRowView: View {
    let entry: JournalEntry
    @Environment(JournalStore.self) private var journalStore
    @Environment(RecipeStore.self) private var recipeStore

    private let thumbnailWidth: CGFloat = 80

    private var recipeName: String {
        recipeStore.recipe(withId: entry.recipeId)?.name ?? "Deleted Recipe"
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: entry.createdAt)
    }

    var body: some View {
        HStack(spacing: 0) {
            if entry.photoCount > 0,
               let image = journalStore.loadThumbnail(for: entry.id) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: thumbnailWidth, height: thumbnailWidth)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color("FormRowBackground"))
                    .frame(width: thumbnailWidth, height: thumbnailWidth)
                    .overlay {
                        Image(systemName: "book.pages")
                            .foregroundStyle(Color("TextTertiary"))
                    }
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipeName)
                        .font(.headline)
                        .foregroundStyle(Color("TextPrimary"))

                    Text(formattedDate)
                        .font(.subheadline)
                        .foregroundStyle(Color("TextSecondary"))

                    StarRatingDisplayView(rating: entry.rating)
                }

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    List {
        JournalRowView(entry: JournalEntry(recipeId: UUID(), rating: 4))
    }
    .environment(JournalStore())
    .environment(RecipeStore())
}
