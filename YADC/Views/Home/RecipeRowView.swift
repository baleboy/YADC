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

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(recipe.name)
                .font(.headline)
                .foregroundStyle(Color("TextPrimary"))

            HStack(spacing: 12) {
                Label("\(recipe.numberOfBalls)", systemImage: "circle.fill")
                Label("\(store.displayWeight(recipe.weightPerBall).weightFormatted) \(store.weightUnit)", systemImage: "scalemass")
                Label("\(recipe.hydration.percentageFormatted)%", systemImage: "drop")
            }
            .font(.subheadline)
            .foregroundStyle(Color("TextSecondary"))

            if !recipe.steps.isEmpty {
                Text("\(recipe.steps.count) step\(recipe.steps.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(Color("TextTertiary"))
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
