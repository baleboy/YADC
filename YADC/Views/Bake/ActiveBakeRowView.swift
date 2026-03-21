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
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(session.recipeName)
                    .font(AppFont.serifHeadline(18))
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

            // Progress bar
            HStack(spacing: 3) {
                ForEach(0..<max(session.totalSteps, 1), id: \.self) { index in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(index <= session.currentStepIndex ? Color("AccentColor") : Color("SurfaceContainerHighest"))
                        .frame(height: 4)
                }
            }

            HStack {
                Text("\(Int(session.progress * 100))% complete")
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))
                Spacer()
                Text(session.startedAt.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(Color("TextTertiary"))
            }
        }
        .padding(16)
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
