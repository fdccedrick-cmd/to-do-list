//
//  ReminderViewModel.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/9/26.
//

import Foundation
import Combine
import SwiftUI

class ReminderViewModel: ObservableObject {
    @Published var reminders: [Reminder] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var showError = false
    
    private let reminderRepository: ReminderRepositoryProtocol
    
    init(reminderRepository: ReminderRepositoryProtocol = ReminderRepository()) {
        self.reminderRepository = reminderRepository
    }
    
    // MARK: - Fetch All Reminders
    
    @MainActor
    func fetchAllReminders(for userId: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            reminders = try await reminderRepository.fetchAllReminders(for: userId)
        } catch {
            errorMessage = "Failed to load reminders: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Fetch Reminders for Task
    
    @MainActor
    func fetchReminders(for taskId: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            reminders = try await reminderRepository.fetchReminders(for: taskId)
        } catch {
            errorMessage = "Failed to load reminders: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Create Reminder
    
    @MainActor
    func createReminder(
        taskId: UUID,
        userId: UUID,
        remindAt: Date,
        taskTitle: String
    ) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newReminder = try await reminderRepository.createReminder(
                taskId: taskId,
                userId: userId,
                remindAt: remindAt,
                taskTitle: taskTitle
            )
            
            reminders.append(newReminder)
            reminders.sort { $0.remindAt < $1.remindAt }
        } catch {
            errorMessage = "Failed to create reminder: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Delete Reminder
    
    @MainActor
    func deleteReminder(_ reminder: Reminder) async {
        do {
            try await reminderRepository.deleteReminder(reminder)
            reminders.removeAll { $0.id == reminder.id }
        } catch {
            errorMessage = "Failed to delete reminder: \(error.localizedDescription)"
            showError = true
        }
    }
    
    // MARK: - Computed Properties
    
    var upcomingReminders: [Reminder] {
        reminders.filter { $0.remindAt > Date() && !$0.isSent }
    }
    
    var pastReminders: [Reminder] {
        reminders.filter { $0.remindAt <= Date() || $0.isSent }
    }
}
