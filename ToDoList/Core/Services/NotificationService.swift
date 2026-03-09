//
//  NotificationService.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation
import UserNotifications

class NotificationService: NSObject {
    static let shared = NotificationService()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    // MARK: - Permission
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            return granted
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Schedule Task Reminder
    func scheduleTaskReminder(
        taskId: UUID,
        title: String,
        body: String,
        date: Date,
        sound: UNNotificationSound = .default
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound
        content.badge = 1
        content.userInfo = [
            "taskId": taskId.uuidString,
            "type": "task_reminder"
        ]
        
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )
        
        let identifier = "task-reminder-\(taskId.uuidString)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        try await notificationCenter.add(request)
    }
    
    // MARK: - Schedule Multiple Reminders
    func scheduleTaskReminders(
        taskId: UUID,
        title: String,
        reminderDates: [Date]
    ) async throws {
        for (index, date) in reminderDates.enumerated() {
            guard date > Date() else { continue } // Skip past dates
            
            let content = UNMutableNotificationContent()
            content.title = "Reminder: \(title)"
            content.body = "Don't forget to complete this task"
            content.sound = .default
            content.badge = 1
            content.userInfo = [
                "taskId": taskId.uuidString,
                "type": "task_reminder",
                "reminderIndex": index
            ]
            
            let calendar = Calendar.current
            let components = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: date
            )
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: false
            )
            
            let identifier = "task-reminder-\(taskId.uuidString)-\(index)"
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
            
            try await notificationCenter.add(request)
        }
    }
    
    // MARK: - Cancel
    func cancelTaskReminders(taskId: UUID) {
        // Cancel all reminders for this task
        notificationCenter.getPendingNotificationRequests { requests in
            let identifiers = requests
                .filter { $0.identifier.contains(taskId.uuidString) }
                .map { $0.identifier }
            
            self.notificationCenter.removePendingNotificationRequests(
                withIdentifiers: identifiers
            )
        }
    }
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    // MARK: - Query
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let taskIdString = userInfo["taskId"] as? String,
           let taskId = UUID(uuidString: taskIdString) {
            // Post notification to open task detail
            NotificationCenter.default.post(
                name: NSNotification.Name("OpenTaskDetail"),
                object: nil,
                userInfo: ["taskId": taskId]
            )
        }
        
        completionHandler()
    }
}
