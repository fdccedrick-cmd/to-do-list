//
//  ReminderRepository.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/9/26.
//

import Foundation

protocol ReminderRepositoryProtocol {
    func fetchReminders(for taskId: UUID) async throws -> [Reminder]
    func fetchAllReminders(for userId: UUID) async throws -> [Reminder]
    func createReminder(taskId: UUID, userId: UUID, remindAt: Date, taskTitle: String) async throws -> Reminder
    func deleteReminder(_ reminder: Reminder) async throws
    func deleteReminders(for taskId: UUID) async throws
}

class ReminderRepository: ReminderRepositoryProtocol {
    private let reminderService: ReminderService
    
    init(reminderService: ReminderService = ReminderService()) {
        self.reminderService = reminderService
    }
    
    func fetchReminders(for taskId: UUID) async throws -> [Reminder] {
        return try await reminderService.fetchReminders(for: taskId)
    }
    
    func fetchAllReminders(for userId: UUID) async throws -> [Reminder] {
        return try await reminderService.fetchAllReminders(for: userId)
    }
    
    func createReminder(taskId: UUID, userId: UUID, remindAt: Date, taskTitle: String) async throws -> Reminder {
        return try await reminderService.createReminder(
            taskId: taskId,
            userId: userId,
            remindAt: remindAt,
            taskTitle: taskTitle
        )
    }
    
    func deleteReminder(_ reminder: Reminder) async throws {
        try await reminderService.deleteReminder(reminder)
    }
    
    func deleteReminders(for taskId: UUID) async throws {
        try await reminderService.deleteReminders(for: taskId)
    }
}
