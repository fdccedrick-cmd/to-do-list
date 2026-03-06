//
//  SubtaskService.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation
import Supabase

class SubtaskService {
    private let supabase = SupabaseManager.shared.client

    // MARK: - Fetch
    func fetchSubtasks(for taskId: UUID) async throws -> [Subtask] {
        let response: [Subtask] = try await supabase
            .from("subtasks")
            .select()
            .eq("task_id", value: taskId.uuidString)
            .order("sort_order", ascending: true)
            .execute()
            .value
        return response
    }

    // MARK: - Create
    func createSubtask(taskId: UUID, title: String, sortOrder: Int) async throws -> Subtask {
        let insert = SubtaskInsert(
            id: UUID(),
            taskId: taskId,
            title: title,
            isCompleted: false,
            sortOrder: sortOrder
        )

        let response: Subtask = try await supabase
            .from("subtasks")
            .insert(insert)
            .select()
            .single()
            .execute()
            .value
        return response
    }

    // MARK: - Toggle
    func toggleSubtask(_ subtask: Subtask) async throws -> Subtask {
        let update = SubtaskUpdate(
            title: nil,
            isCompleted: !subtask.isCompleted,
            sortOrder: nil
        )

        let response: Subtask = try await supabase
            .from("subtasks")
            .update(update)
            .eq("id", value: subtask.id.uuidString)
            .select()
            .single()
            .execute()
            .value
        return response
    }

    // MARK: - Update Title
    func updateSubtask(_ subtask: Subtask) async throws -> Subtask {
        let update = SubtaskUpdate(
            title: subtask.title,
            isCompleted: subtask.isCompleted,
            sortOrder: subtask.sortOrder
        )

        let response: Subtask = try await supabase
            .from("subtasks")
            .update(update)
            .eq("id", value: subtask.id.uuidString)
            .select()
            .single()
            .execute()
            .value
        return response
    }

    // MARK: - Delete
    func deleteSubtask(_ subtask: Subtask) async throws {
        try await supabase
            .from("subtasks")
            .delete()
            .eq("id", value: subtask.id.uuidString)
            .execute()
    }
}

// MARK: - Insert/Update DTOs
struct SubtaskInsert: Codable {
    let id: UUID
    let taskId: UUID
    let title: String
    let isCompleted: Bool
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id
        case taskId = "task_id"
        case title
        case isCompleted = "is_completed"
        case sortOrder = "sort_order"
    }
}

struct SubtaskUpdate: Codable {
    let title: String?
    let isCompleted: Bool?
    let sortOrder: Int?

    enum CodingKeys: String, CodingKey {
        case title
        case isCompleted = "is_completed"
        case sortOrder = "sort_order"
    }
}
