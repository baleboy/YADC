//
//  AppDelegate.swift
//  YADC
//
//  Created by Claude on 1.2.2026.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // Called when user taps on a notification while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show the notification even when app is in foreground
        completionHandler([.banner, .sound])
    }

    // Called when user taps on a notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        // Extract session ID from notification userInfo
        if let sessionIdString = userInfo["sessionId"] as? String,
           let sessionId = UUID(uuidString: sessionIdString) {
            // Trigger navigation to the bake session
            DispatchQueue.main.async {
                NavigationManager.shared.navigateToBakeSession(sessionId)
            }
        }

        completionHandler()
    }
}
