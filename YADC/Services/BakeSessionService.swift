//
//  BakeSessionService.swift
//  YADC
//
//  Created by Claude on 25.1.2026.
//

import Foundation

@Observable
final class BakeSessionService {
    static let shared = BakeSessionService()

    private static let storageKey = "activeBakeSessions"

    private(set) var activeSessions: [UUID: BakeSession] = [:]

    private init() {
        loadSessions()
    }

    // MARK: - Session Management

    func startSession(
        recipe: Recipe,
        scaledNumberOfBalls: Int,
        scaledWeightPerBall: Double,
        scaledIngredients: [Ingredient]
    ) -> BakeSession {
        let session = BakeSession(
            recipeId: recipe.id,
            recipeName: recipe.name,
            scaledNumberOfBalls: scaledNumberOfBalls,
            scaledWeightPerBall: scaledWeightPerBall,
            scaledIngredients: scaledIngredients,
            steps: recipe.steps
        )

        activeSessions[session.id] = session
        saveSessions()
        return session
    }

    func session(withId id: UUID) -> BakeSession? {
        activeSessions[id]
    }

    func advanceStep(for sessionId: UUID) {
        guard var session = activeSessions[sessionId] else { return }
        if session.hasNextStep {
            session.currentStepIndex += 1
            activeSessions[sessionId] = session
            saveSessions()
        }
    }

    func goToPreviousStep(for sessionId: UUID) {
        guard var session = activeSessions[sessionId] else { return }
        if session.hasPreviousStep {
            session.currentStepIndex -= 1
            activeSessions[sessionId] = session
            saveSessions()
        }
    }

    func completeSession(_ sessionId: UUID) {
        activeSessions.removeValue(forKey: sessionId)
        saveSessions()
    }

    func cancelSession(_ sessionId: UUID) {
        // Stop any running timers for this session's steps
        if let session = activeSessions[sessionId] {
            for step in session.steps {
                TimerService.shared.stopTimer(for: step.id)
            }
        }
        activeSessions.removeValue(forKey: sessionId)
        saveSessions()
    }

    var hasActiveSessions: Bool {
        !activeSessions.isEmpty
    }

    var activeSessionCount: Int {
        activeSessions.count
    }

    var allSessions: [BakeSession] {
        Array(activeSessions.values).sorted { $0.startedAt > $1.startedAt }
    }

    // MARK: - Persistence

    private func saveSessions() {
        let sessionsArray = Array(activeSessions.values)
        if let data = try? JSONEncoder().encode(sessionsArray) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    private func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let sessionsArray = try? JSONDecoder().decode([BakeSession].self, from: data) else {
            return
        }

        activeSessions = [:]
        for session in sessionsArray {
            activeSessions[session.id] = session
        }
    }
}
