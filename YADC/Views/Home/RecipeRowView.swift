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

    private var ratingInfo: (average: Double, count: Int)? {
        journalStore.ratingInfo(for: recipe.id)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Hero image
            if recipe.hasImage,
               let image = imageService.loadImage(for: recipe.id) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(4/3, contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color("SurfaceContainerHigh"))
                    .frame(height: 140)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(Color("TextTertiary").opacity(0.5))
                    }
            }

            // Content
            VStack(alignment: .leading, spacing: 10) {
                // Timer badge overlay
                if timerService.hasRunningTimers(for: recipe) {
                    let count = timerService.runningTimerCount(for: recipe)
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                        Text("\(count) active")
                            .fontWeight(.semibold)
                    }
                    .font(.caption2)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color("AccentColor"))
                    .clipShape(Capsule())
                }

                Text(recipe.name)
                    .font(AppFont.serifHeadline(20))
                    .foregroundStyle(Color("TextPrimary"))

                // Stats row
                HStack(spacing: 16) {
                    statItem(value: recipe.hydration.percentageFormatted, label: "HYDRATION")
                    statItem(value: "\(recipe.numberOfBalls)", label: "BALLS")
                    statItem(value: "\(store.displayWeight(recipe.weightPerBall).weightFormatted)\(store.weightUnit)", label: "PER BALL")
                }

                // Bottom row: steps, prep time, rating
                HStack(spacing: 12) {
                    if !recipe.steps.isEmpty {
                        Label("\(recipe.steps.count) step\(recipe.steps.count == 1 ? "" : "s")", systemImage: "list.number")
                    }

                    if let prepTime = recipe.formattedPreparationTime {
                        Label(prepTime, systemImage: "clock")
                    }

                    Spacer()

                    if let rating = ratingInfo {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(Color("AccentColor"))
                            Text(String(format: "%.1f", rating.average))
                                .fontWeight(.medium)
                        }
                    }
                }
                .font(.caption)
                .foregroundStyle(Color("TextSecondary"))
            }
            .padding(16)
        }
        .background(Color("SurfaceContainerLowest"))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color("TextPrimary"))
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .tracking(1.0)
                .foregroundStyle(Color("TextSecondary").opacity(0.7))
        }
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
