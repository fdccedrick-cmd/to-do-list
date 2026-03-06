//
//  SubtaskRepository.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation

// MARK: - Protocol
protocol SubtaskRepositoryProtocol {
    func fetchSubtasks(for taskId: UUID) async throws -> [Subtask]
    func createSubtask(taskId: UUID, title: String, sortOrder: Int) async throws -> Subtask
    func toggleSubtask(_ subtask: Subtask) async throws -> Subtask
    func updateSubtask(_ subtask: Subtask) async throws -> Subtask
    func deleteSubtask(_ subtask: Subtask) async throws
}

// MARK: - Implementation
class SubtaskRepository: SubtaskRepositoryProtocol {
    private let subtaskService: SubtaskService

    init(subtaskService: SubtaskService = SubtaskService()) {
        self.subtaskService = subtaskService
    }

    func fetchSubtasks(for taskId: UUID) async throws -> [Subtask] {
        return try await subtaskService.fetchSubtasks(for: taskId)
    }

    func createSubtask(taskId: UUID, title: String, sortOrder: Int) async throws -> Subtask {
        return try await subtaskService.createSubtask(
            taskId: taskId,
            title: title,
            sortOrder: sortOrder
        )
    }

    func toggleSubtask(_ subtask: Subtask) async throws -> Subtask {
        return try await subtaskService.toggleSubtask(subtask)
    }

    func updateSubtask(_ subtask: Subtask) async throws -> Subtask {
        return try await subtaskService.updateSubtask(subtask)
    }

    func deleteSubtask(_ subtask: Subtask) async throws {
        try await subtaskService.deleteSubtask(subtask)
    }
}
