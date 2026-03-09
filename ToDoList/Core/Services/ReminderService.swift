//
//  ReminderService.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation
import Supabase

class ReminderService {
    private let client = SupabaseManager.shared.client
    private let notificationService = NotificationService.shared
    
    // MARK: - Fetch
    func fetchReminders(for taskId: UUID) async throws -> [Reminder] {
        let response: [Reminder] = try await client
            .from(SupabaseConfig.Tables.reminders)
            .select()
            .eq("task_id", value: taskId.uuidString)
            .order("remind_at")
            .execute()
            .value
        
        return response
    }
    
    // MARK: - Create
    func createReminder(
        taskId: UUID,
        userId: UUID,
        remindAt: Date,
        taskTitle: String
    ) async throws -> Reminder {
        struct ReminderInsert: Encodable {
            let task_id: String
            let user_id: String
            let remind_at: String
            let is_sent: Bool
        }
        
        let reminderInsert = ReminderInsert(
            task_id: taskId.uuidString,
            user_id: userId.uuidString,
            remind_at: ISO8601DateFormatter().string(from: remindAt),
            is_sent: false
        )
        
        let response: Reminder = try await client
            .from(SupabaseConfig.Tables.reminders)
            .insert(reminderInsert)
            .select()
            .single()
            .execute()
            .value
        
        // Schedule local notification
        try await notificationService.scheduleTaskReminder(
            taskId: taskId,
            title: "Reminder: \(taskTitle)",
            body: "Don't forget to complete this task",
            date: remindAt
        )
        
        return response
    }
    
    // MARK: - Create Multiple
    func createReminders(
        taskId: UUID,
        userId: UUID,
        reminderDates: [Date],
        taskTitle: String
    ) async throws -> [Reminder] {
        var createdReminders: [Reminder] = []
        
        for date in reminderDates {
            let reminder = try await createReminder(
                taskId: taskId,
                userId: userId,
                remindAt: date,
                taskTitle: taskTitle
            )
            createdReminders.append(reminder)
        }
        
        return createdReminders
    }
    
    // MARK: - Delete
    func deleteReminder(_ reminder: Reminder) async throws {
        try await client
            .from(SupabaseConfig.Tables.reminders)
            .delete()
            .eq("id", value: reminder.id.uuidString)
            .execute()
        
        // Cancel notification
        notificationService.cancelTaskReminders(taskId: reminder.taskId)
    }
    
    // MARK: - Delete All for Task
    func deleteReminders(for taskId: UUID) async throws {
        try await client
            .from(SupabaseConfig.Tables.reminders)
            .delete()
            .eq("task_id", value: taskId.uuidString)
            .execute()
        
        // Cancel notifications
        notificationService.cancelTaskReminders(taskId: taskId)
    }
    
    // MARK: - Mark as Sent
    func markAsSent(_ reminder: Reminder) async throws {
        try await client
            .from(SupabaseConfig.Tables.reminders)
            .update(["is_sent": true])
            .eq("id", value: reminder.id.uuidString)
            .execute()
    }
}
