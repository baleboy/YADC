//
//  ActiveBakeRowView.swift
//  YADC
//
//  Created by Claude on 25.1.2026.
//

import SwiftUI

struct ActiveBakeRowView: View {
    let session: BakeSession
    @Environment(RecipeStore.self) private var store

    private var timerService: TimerService { .shared }

    private var hasActiveTimer: Bool {
        guard let currentStep = session.currentStep else { return false }
        return timerService.isTimerActive(for: currentStep.id)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.recipeName)
                    .font(.headline)
                    .foregroundStyle(Color("TextPrimary"))

                Spacer()

                if hasActiveTimer {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(Color("AccentColor"))
                        .font(.caption)
                }

                Image(systemName: "chevron.right")
                    .foregroundStyle(Color("TextTertiary"))
                    .font(.caption)
            }

            if let currentStep = session.currentStep {
                Text("Step \(session.currentStepIndex + 1): \(currentStep.description)")
                    .font(.subheadline)
                    .foregroundStyle(Color("TextSecondary"))
                    .lineLimit(2)
            }

            HStack {
                ProgressView(value: session.progress)
                    .tint(Color("AccentColor"))

                Text("\(Int(session.progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))
                    .frame(width: 40, alignment: .trailing)
            }

            Text("Started \(session.startedAt.formatted(.relative(presentation: .named)))")
                .font(.caption2)
                .foregroundStyle(Color("TextTertiary"))
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    List {
        ActiveBakeRowView(session: BakeSession(
            recipeId: UUID(),
            recipeName: "Pizza Dough",
            scaledNumberOfBalls: 4,
            scaledWeightPerBall: 250,
            scaledIngredients: [],
            steps: [
                Step(description: "Mix flour and water", order: 0),
                Step(description: "Add salt and yeast", order: 1),
                Step(description: "Knead for 10 minutes", order: 2)
            ]
        ))
        .listRowBackground(Color("FormRowBackground"))
    }
    .environment(RecipeStore())
}
