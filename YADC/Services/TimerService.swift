//
//  TimerService.swift
//  YADC
//
//  Created by Claude on 13.12.2025.
//

import Foundation
import UserNotifications

@Observable
final class TimerService {
    static let shared = TimerService()

    private static let storageKey = "activeTimers"
    private static let expiredStorageKey = "expiredTimers"

    private(set) var activeTimers: [UUID: TimerState] = [:]
    private(set) var expiredTimers: [TimerState] = []

    struct TimerState: Codable, Identifiable {
        var id: UUID { stepId }
        let stepId: UUID
        let stepDescription: String
        var startTime: Date
        var durationSeconds: Int
        var notificationId: String
        var isPaused: Bool = false
        var remainingSecondsWhenPaused: Int?
        var expiredAt: Date?

        var endTime: Date {
            startTime.addingTimeInterval(TimeInterval(durationSeconds))
        }

        var remainingSeconds: Int {
            if isPaused, let paused = remainingSecondsWhenPaused {
                return paused
            }
            return max(0, Int(endTime.timeIntervalSinceNow))
        }

        var isExpired: Bool {
            !isPaused && remainingSeconds <= 0
        }
    }

    private init() {
        loadTimers()
        updateTimers()
    }

    // MARK: - Notification Permissions

    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    // MARK: - Timer Management

    func startTimer(for step: Step) {
        guard let minutes = step.waitingTimeMinutes, minutes > 0 else { return }

        let notificationId = "step-timer-\(step.id.uuidString)"

        let state = TimerState(
            stepId: step.id,
            stepDescription: step.description,
            startTime: Date(),
            durationSeconds: minutes * 60,
            notificationId: notificationId
        )

        activeTimers[step.id] = state
        scheduleNotification(for: state)
        saveTimers()
    }

    func stopTimer(for stepId: UUID) {
        guard let state = activeTimers[stepId] else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [state.notificationId])
        activeTimers.removeValue(forKey: stepId)
        saveTimers()
    }

    func pauseTimer(for stepId: UUID) {
        guard var state = activeTimers[stepId], !state.isPaused else { return }

        // Cancel the notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [state.notificationId])

        // Save remaining time and mark as paused
        state.remainingSecondsWhenPaused = state.remainingSeconds
        state.isPaused = true
        activeTimers[stepId] = state
        saveTimers()
    }

    func resumeTimer(for stepId: UUID) {
        guard var state = activeTimers[stepId],
              state.isPaused,
              let remainingSeconds = state.remainingSecondsWhenPaused else { return }

        // Reset start time based on remaining seconds
        state.startTime = Date()
        state.durationSeconds = remainingSeconds
        state.isPaused = false
        state.remainingSecondsWhenPaused = nil

        activeTimers[stepId] = state

        // Reschedule notification
        scheduleNotification(for: state)
        saveTimers()
    }

    func isTimerActive(for stepId: UUID) -> Bool {
        guard let state = activeTimers[stepId] else { return false }
        return !state.isExpired
    }

    func isTimerPaused(for stepId: UUID) -> Bool {
        guard let state = activeTimers[stepId] else { return false }
        return state.isPaused
    }

    func remainingTime(for stepId: UUID) -> Int? {
        guard let state = activeTimers[stepId], !state.isExpired else { return nil }
        return state.remainingSeconds
    }

    func runningTimerCount(for recipe: Recipe) -> Int {
        recipe.steps.filter { isTimerActive(for: $0.id) }.count
    }

    func hasRunningTimers(for recipe: Recipe) -> Bool {
        runningTimerCount(for: recipe) > 0
    }

    var totalRunningTimerCount: Int {
        activeTimers.values.filter { !$0.isExpired }.count
    }

    func dismissExpiredTimer(_ timer: TimerState) {
        expiredTimers.removeAll { $0.stepId == timer.stepId }
        saveExpiredTimers()
    }

    func dismissAllExpiredTimers() {
        expiredTimers.removeAll()
        saveExpiredTimers()
    }

    func recipe(for stepId: UUID, in recipes: [Recipe]) -> Recipe? {
        recipes.first { recipe in
            recipe.steps.contains { $0.id == stepId }
        }
    }

    // MARK: - Notifications

    private func scheduleNotification(for state: TimerState) {
        let content = UNMutableNotificationContent()
        content.title = "Timer Complete"
        content.body = "Step complete: \(state.stepDescription)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(state.durationSeconds),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: state.notificationId,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Timer Updates

    func updateTimers() {
        var changed = false
        for (stepId, state) in activeTimers {
            if state.isExpired {
                var expiredState = state
                expiredState.expiredAt = Date()
                expiredTimers.insert(expiredState, at: 0)
                activeTimers.removeValue(forKey: stepId)
                changed = true
            }
        }
        if changed {
            saveTimers()
            saveExpiredTimers()
        }
    }

    // MARK: - Persistence

    private func saveTimers() {
        let timersArray = Array(activeTimers.values)
        if let data = try? JSONEncoder().encode(timersArray) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    private func saveExpiredTimers() {
        if let data = try? JSONEncoder().encode(expiredTimers) {
            UserDefaults.standard.set(data, forKey: Self.expiredStorageKey)
        }
    }

    private func loadTimers() {
        // Load active timers
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let timersArray = try? JSONDecoder().decode([TimerState].self, from: data) {
            activeTimers = [:]
            for timer in timersArray {
                activeTimers[timer.stepId] = timer
            }
        }

        // Load expired timers
        if let data = UserDefaults.standard.data(forKey: Self.expiredStorageKey),
           let expired = try? JSONDecoder().decode([TimerState].self, from: data) {
            expiredTimers = expired
        }
    }
}
