//
//  RecipeRowView.swift
//  YADC
//
//  Created by Francesco Balestrieri on 14.12.2025.
//

import SwiftUI

struct RecipeRowView: View {
    let recipe: Recipe
    @Environment(RecipeStore.self) private var store
    @Environment(JournalStore.self) private var journalStore
    private let imageService = ImageService.shared

    private var ratingInfo: (average: Double, count: Int)? {
        journalStore.ratingInfo(for: recipe.id)
    }

    var body: some View {
        HStack(spacing: 14) {
            // Thumbnail
            if recipe.hasImage,
               let image = imageService.loadImage(for: recipe.id) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
            } else {
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .fill(Color("FormRowBackground"))
                    .frame(width: 80, height: 80)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundStyle(Color("TextTertiary").opacity(0.5))
                    }
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(AppFont.body(16, weight: .semibold))
                    .foregroundStyle(Color("TextPrimary"))

                Text(recipeSubtitle)
                    .font(AppFont.body(13))
                    .foregroundStyle(Color("TextSecondary"))

                // Meta row: hydration badge + rating
                HStack(spacing: 10) {
                    // Hydration badge
                    Text(recipe.hydration.percentageFormatted)
                        .font(AppFont.caption(11, weight: .semibold))
                        .foregroundStyle(Color("AccentColor"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color("AccentGreenLight"))
                        .clipShape(Capsule())

                    // Rating + bake count
                    if let rating = ratingInfo {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color("AccentCoral"))
                            Text(String(format: "%.1f", rating.average))
                                .font(AppFont.caption(12, weight: .medium))
                                .foregroundStyle(Color("TextSecondary"))
                            Text("·")
                                .foregroundStyle(Color("TextTertiary"))
                            Text("\(rating.count) bake\(rating.count == 1 ? "" : "s")")
                                .font(AppFont.caption(12, weight: .medium))
                                .foregroundStyle(Color("TextSecondary"))
                        }
                    }
                }
                .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.init(top: 10, leading: 10, bottom: 10, trailing: 14))
        .background(Color("SurfaceContainerLowest"))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))
        .shadow(color: Color(red: 0.1, green: 0.1, blue: 0.09).opacity(0.03), radius: 12, x: 0, y: 2)
    }

    private var recipeSubtitle: String {
        let count = recipe.numberOfBalls
        let weight = store.displayWeight(recipe.weightPerBall).weightFormatted
        let unit = store.weightUnit
        if count == 1 {
            return "1 ball · \(weight)\(unit)"
        }
        return "\(count) balls · \(weight)\(unit) each"
    }
}

#Preview {
    ScrollView {
        RecipeRowView(recipe: Recipe.default)
            .padding()
    }
    .background(Color("CreamBackground"))
    .environment(RecipeStore())
    .environment(JournalStore())
}
