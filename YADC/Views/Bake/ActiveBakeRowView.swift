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

    private var remainingTimeText: String? {
        guard let currentStep = session.currentStep else { return nil }
        if let remaining = timerService.remainingTime(for: currentStep.id) {
            let minutes = remaining / 60
            let seconds = remaining % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
        if let waitingTime = currentStep.waitingTimeMinutes, waitingTime > 0 {
            return "\(waitingTime):00"
        }
        return nil
    }

    var body: some View {
        HStack(spacing: 14) {
            // Circle icon
            ZStack {
                Circle()
                    .fill(Color("AccentGreenLight"))
                    .frame(width: 48, height: 48)
                Image(systemName: "timer")
                    .font(.system(size: 18))
                    .foregroundStyle(Color("AccentColor"))
            }

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(session.recipeName)
                    .font(AppFont.body(16, weight: .semibold))
                    .foregroundStyle(Color("TextPrimary"))

                if let currentStep = session.currentStep {
                    Text("Step \(session.currentStepIndex + 1) of \(session.totalSteps) · \(currentStep.description)")
                        .font(AppFont.caption(13, weight: .medium))
                        .foregroundStyle(Color("TextSecondary"))
                        .lineLimit(1)
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color("FormRowBackground"))
                            .frame(height: 6)
                        Capsule()
                            .fill(Color("AccentColor"))
                            .frame(width: geometry.size.width * session.progress, height: 6)
                    }
                }
                .frame(height: 6)
            }

            // Timer display
            if let timeText = remainingTimeText {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(timeText)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .tracking(-0.5)
                        .foregroundStyle(Color("AccentColor"))
                        .monospacedDigit()
                    Text("remaining")
                        .font(AppFont.caption(11, weight: .medium))
                        .foregroundStyle(Color("TextTertiary"))
                }
            }
        }
        .padding(16)
        .background(Color("SurfaceContainerLowest"))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.default))
        .shadow(color: Color(red: 0.1, green: 0.1, blue: 0.09).opacity(0.03), radius: 12, x: 0, y: 2)
        .contentShape(Rectangle())
    }
}

#Preview {
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
    .padding()
    .background(Color("CreamBackground"))
    .environment(RecipeStore())
}
