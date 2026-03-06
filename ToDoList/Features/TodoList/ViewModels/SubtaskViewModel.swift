//
//  SubtaskViewModel.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//


import Foundation
import Combine

class SubtaskViewModel: ObservableObject {
    // MARK: - Published
    @Published var subtasks: [Subtask] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var showError = false

    // MARK: - Computed
    var completedCount: Int { subtasks.filter { $0.isCompleted }.count }
    var totalCount: Int { subtasks.count }
    var progress: Double { totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0 }
    var progressText: String { "\(completedCount)/\(totalCount)" }
    var allCompleted: Bool { !subtasks.isEmpty && completedCount == totalCount }

    // MARK: - Dependencies
    private let repository: SubtaskRepositoryProtocol
    private let taskId: UUID

    init(taskId: UUID, repository: SubtaskRepositoryProtocol = SubtaskRepository()) {
        self.taskId = taskId
        self.repository = repository
    }

    // MARK: - Fetch
    @MainActor
    func fetchSubtasks() async {
        isLoading = true
        do {
            subtasks = try await repository.fetchSubtasks(for: taskId)
        } catch {
            errorMessage = "Failed to load subtasks: \(error.localizedDescription)"
            showError = true
        }
        isLoading = false
    }

    // MARK: - Create
    @MainActor
    func createSubtask(title: String) async {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        do {
            let newSubtask = try await repository.createSubtask(
                taskId: taskId,
                title: title.trimmingCharacters(in: .whitespaces),
                sortOrder: subtasks.count
            )
            subtasks.append(newSubtask)
        } catch {
            errorMessage = "Failed to create subtask: \(error.localizedDescription)"
            showError = true
        }
    }

    // MARK: - Toggle
    @MainActor
    func toggleSubtask(_ subtask: Subtask) async {
        do {
            let updated = try await repository.toggleSubtask(subtask)
            if let index = subtasks.firstIndex(where: { $0.id == subtask.id }) {
                subtasks[index] = updated
            }
        } catch {
            errorMessage = "Failed to update subtask: \(error.localizedDescription)"
            showError = true
        }
    }

    // MARK: - Delete
    @MainActor
    func deleteSubtask(_ subtask: Subtask) async {
        do {
            try await repository.deleteSubtask(subtask)
            subtasks.removeAll { $0.id == subtask.id }
        } catch {
            errorMessage = "Failed to delete subtask: \(error.localizedDescription)"
            showError = true
        }
    }

    // MARK: - Delete at offsets (for swipe)
    @MainActor
    func deleteSubtasks(at offsets: IndexSet) async {
        for index in offsets {
            await deleteSubtask(subtasks[index])
        }
    }
}
