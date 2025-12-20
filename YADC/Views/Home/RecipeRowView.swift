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

    var body: some View {
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
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        RecipeRowView(recipe: Recipe.default)
    }
    .environment(RecipeStore())
}
