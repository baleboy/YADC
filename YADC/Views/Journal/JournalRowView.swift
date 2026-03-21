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

    private var recipeName: String {
        recipeStore.recipe(withId: entry.recipeId)?.name ?? "Deleted Recipe"
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: entry.createdAt)
    }

    var body: some View {
        HStack(spacing: 14) {
            // Image
            if entry.photoCount > 0,
               let image = journalStore.loadThumbnail(for: entry.id) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
            } else {
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .fill(Color("SurfaceContainerHigh"))
                    .frame(width: 80, height: 80)
                    .overlay {
                        Image(systemName: "book.pages")
                            .font(.title3)
                            .foregroundStyle(Color("TextTertiary").opacity(0.5))
                    }
            }

            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(formattedDate.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1.0)
                    .foregroundStyle(Color("AccentColor"))

                Text(recipeName)
                    .font(AppFont.serifHeadline(18))
                    .foregroundStyle(Color("TextPrimary"))

                StarRatingDisplayView(rating: entry.rating)

                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .font(AppFont.serifItalic(13))
                        .foregroundStyle(Color("TextSecondary"))
                        .lineLimit(2)
                }
            }

            Spacer()
        }
        .padding(14)
        .background(Color("FormRowBackground"))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
    }
}

#Preview {
    JournalRowView(entry: JournalEntry(recipeId: UUID(), rating: 4))
        .padding()
        .background(Color("CreamBackground"))
        .environment(JournalStore())
        .environment(RecipeStore())
}
