//
//  BakeSession.swift
//  YADC
//
//  Created by Claude on 25.1.2026.
//

import Foundation

struct BakeSession: Identifiable, Codable, Equatable {
    let id: UUID
    let recipeId: UUID
    let recipeName: String
    var currentStepIndex: Int
    var scaledNumberOfBalls: Int
    var scaledWeightPerBall: Double
    var scaledIngredients: [Ingredient]
    var steps: [Step]
    var startedAt: Date

    init(
        id: UUID = UUID(),
        recipeId: UUID,
        recipeName: String,
        currentStepIndex: Int = 0,
        scaledNumberOfBalls: Int,
        scaledWeightPerBall: Double,
        scaledIngredients: [Ingredient],
        steps: [Step],
        startedAt: Date = Date()
    ) {
        self.id = id
        self.recipeId = recipeId
        self.recipeName = recipeName
        self.currentStepIndex = currentStepIndex
        self.scaledNumberOfBalls = scaledNumberOfBalls
        self.scaledWeightPerBall = scaledWeightPerBall
        self.scaledIngredients = scaledIngredients
        self.steps = steps
        self.startedAt = startedAt
    }

    var scaledTotalWeight: Double {
        Double(scaledNumberOfBalls) * scaledWeightPerBall
    }

    var currentStep: Step? {
        guard currentStepIndex >= 0 && currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }

    var hasNextStep: Bool {
        currentStepIndex < steps.count - 1
    }

    var hasPreviousStep: Bool {
        currentStepIndex > 0
    }

    var isComplete: Bool {
        currentStepIndex >= steps.count
    }

    var progress: Double {
        guard !steps.isEmpty else { return 1.0 }
        return Double(currentStepIndex + 1) / Double(steps.count)
    }

    var totalSteps: Int {
        steps.count
    }
}
