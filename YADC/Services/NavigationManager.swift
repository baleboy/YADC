//
//  NavigationManager.swift
//  YADC
//
//  Created by Claude on 1.2.2026.
//

import Foundation

@Observable
final class NavigationManager {
    static let shared = NavigationManager()

    /// The session ID to navigate to when a timer notification is tapped
    var pendingBakeSessionId: UUID?

    /// Whether the app should switch to the Bakes tab
    var shouldSwitchToBakesTab: Bool = false

    private init() {}

    /// Called when a timer notification is tapped to trigger navigation
    func navigateToBakeSession(_ sessionId: UUID) {
        pendingBakeSessionId = sessionId
        shouldSwitchToBakesTab = true
    }

    /// Called after navigation is complete to reset state
    func clearPendingNavigation() {
        pendingBakeSessionId = nil
        shouldSwitchToBakesTab = false
    }
}
