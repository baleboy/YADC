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
    private let timerService = TimerService.shared
    private let imageService = ImageService.shared

    private let thumbnailWidth: CGFloat = 80

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

                    if !recipe.steps.isEmpty {
                        Text("\(recipe.steps.count) step\(recipe.steps.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(Color("TextTertiary"))
                    }
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
}
