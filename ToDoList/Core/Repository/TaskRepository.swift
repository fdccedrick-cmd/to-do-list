//
//  TaskRepository.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation

/// Protocol defining task data operations
protocol TaskRepositoryProtocol {
    func fetchTasks(for userId: UUID) async throws -> [Task]
    func fetchIncompleteTasks(for userId: UUID) async throws -> [Task]
    func fetchCompletedTasks(for userId: UUID) async throws -> [Task]
    func fetchTasks(for userId: UUID, categoryId: UUID) async throws -> [Task]
    func createTask(userId: UUID, title: String, description: String, priority: TaskPriority, categoryId: UUID?, dueDate: Date?, dueTime: String?) async throws -> Task
    func updateTask(_ task: Task) async throws -> Task
    func toggleTaskCompletion(_ task: Task) async throws -> Task
    func deleteTask(_ task: Task) async throws
}

/// Concrete implementation of TaskRepository using TaskService
class TaskRepository: TaskRepositoryProtocol {
    private let taskService: TaskService
    
    init(taskService: TaskService = TaskService()) {
        self.taskService = taskService
    }
    
    func fetchTasks(for userId: UUID) async throws -> [Task] {
        return try await taskService.fetchTasks(for: userId)
    }
    
    func fetchIncompleteTasks(for userId: UUID) async throws -> [Task] {
        return try await taskService.fetchIncompleteTasks(for: userId)
    }
    
    func fetchCompletedTasks(for userId: UUID) async throws -> [Task] {
        return try await taskService.fetchCompletedTasks(for: userId)
    }
    
    func fetchTasks(for userId: UUID, categoryId: UUID) async throws -> [Task] {
        return try await taskService.fetchTasks(for: userId, categoryId: categoryId)
    }
    
    func createTask(
        userId: UUID,
        title: String,
        description: String = "",
        priority: TaskPriority = .medium,
        categoryId: UUID? = nil,
        dueDate: Date? = nil,
        dueTime: String? = nil
    ) async throws -> Task {
        return try await taskService.createTask(
            userId: userId,
            title: title,
            description: description,
            priority: priority,
            categoryId: categoryId,
            dueDate: dueDate,
            dueTime: dueTime
        )
    }
    
    func updateTask(_ task: Task) async throws -> Task {
        return try await taskService.updateTask(task)
    }
    
    func toggleTaskCompletion(_ task: Task) async throws -> Task {
        return try await taskService.toggleTaskCompletion(task)
    }
    
    func deleteTask(_ task: Task) async throws {
        try await taskService.deleteTask(task)
    }
}
