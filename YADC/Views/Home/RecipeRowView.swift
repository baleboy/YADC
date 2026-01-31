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
    private let timerService = TimerService.shared
    private let imageService = ImageService.shared

    private let thumbnailWidth: CGFloat = 80

    private var ratingInfo: (average: Double, count: Int)? {
        journalStore.ratingInfo(for: recipe.id)
    }

    var body: some View {
        HStack(spacing: 0) {
            if recipe.hasImage,
               let image = imageService.loadImage(for: recipe.id) {
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
                        Image(systemName: "photo")
                            .foregroundStyle(Color("TextTertiary"))
                    }
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(.headline)
                        .foregroundStyle(Color("TextPrimary"))

                    HStack(spacing: 12) {
                        Label("\(recipe.numberOfBalls)", systemImage: "circle.grid.2x2")
                        Label("\(store.displayWeight(recipe.weightPerBall).weightFormatted) \(store.weightUnit)", systemImage: "scalemass")
                        Label(recipe.hydration.percentageFormatted, systemImage: "drop")
                    }
                    .labelStyle(.titleAndIcon)
                    .font(.subheadline)
                    .foregroundStyle(Color("TextSecondary"))

                    HStack(spacing: 12) {
                        if !recipe.steps.isEmpty {
                            Text("\(recipe.steps.count) step\(recipe.steps.count == 1 ? "" : "s")")
                                .foregroundStyle(Color("TextTertiary"))
                        }

                        if let prepTime = recipe.formattedPreparationTime {
                            Label(prepTime, systemImage: "clock")
                                .foregroundStyle(Color("TextTertiary"))
                        }

                        if let rating = ratingInfo {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                Text(String(format: "%.1f", rating.average))
                                    .foregroundStyle(Color("TextPrimary"))
                                Text("(\(rating.count))")
                                    .foregroundStyle(Color("TextTertiary"))
                            }
                        } else {
                            Text("No bakes yet")
                                .foregroundStyle(Color("TextTertiary"))
                        }
                    }
                    .font(.caption)
                }

                Spacer()

                if timerService.hasRunningTimers(for: recipe) {
                    let count = timerService.runningTimerCount(for: recipe)
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                        Text("\(count)")
                            .fontWeight(.bold)
                    }
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    List {
        RecipeRowView(recipe: Recipe.default)
    }
    .environment(RecipeStore())
    .environment(JournalStore())
}
