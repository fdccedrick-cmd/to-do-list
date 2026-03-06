//
//  TaskService.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation
import Supabase

class TaskService {
    private let supabase = SupabaseManager.shared.client
    
    // MARK: - Fetch Tasks
    
    /// Fetch all tasks for the current user
    func fetchTasks(for userId: UUID) async throws -> [Task] {
        let response: [Task] = try await supabase
            .from("tasks")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("sort_order", ascending: true)
            .execute()
            .value
        
        return response
    }
    
    /// Fetch incomplete tasks
    func fetchIncompleteTasks(for userId: UUID) async throws -> [Task] {
        let response: [Task] = try await supabase
            .from("tasks")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("is_completed", value: false)
            .order("sort_order", ascending: true)
            .execute()
            .value
        
        return response
    }
    
    /// Fetch completed tasks
    func fetchCompletedTasks(for userId: UUID) async throws -> [Task] {
        let response: [Task] = try await supabase
            .from("tasks")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("is_completed", value: true)
            .order("completed_at", ascending: false)
            .execute()
            .value
        
        return response
    }
    
    /// Fetch tasks by category
    func fetchTasks(for userId: UUID, categoryId: UUID) async throws -> [Task] {
        let response: [Task] = try await supabase
            .from("tasks")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("category_id", value: categoryId.uuidString)
            .order("sort_order", ascending: true)
            .execute()
            .value
        
        return response
    }
    
    // MARK: - Create Task
    
    func createTask(
        userId: UUID,
        title: String,
        description: String = "",
        priority: TaskPriority = .medium,
        categoryId: UUID? = nil,
        dueDate: Date? = nil,
        dueTime: String? = nil
    ) async throws -> Task {
        let taskInsert = TaskInsert(
            id: UUID(),
            userId: userId,
            categoryId: categoryId,
            title: title,
            description: description,
            isCompleted: false,
            priority: priority,
            dueDate: dueDate,
            dueTime: dueTime,
            sortOrder: 0
        )
        
        let response: Task = try await supabase
            .from("tasks")
            .insert(taskInsert)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    // MARK: - Update Task
    
    func updateTask(_ task: Task) async throws -> Task {
        let taskUpdate = TaskUpdate(
            title: task.title,
            description: task.description,
            isCompleted: task.isCompleted,
            priority: task.priority,
            categoryId: task.categoryId,
            dueDate: task.dueDate,
            dueTime: task.dueTime,
            completedAt: task.completedAt,
            sortOrder: task.sortOrder
        )
        
        let response: Task = try await supabase
            .from("tasks")
            .update(taskUpdate)
            .eq("id", value: task.id.uuidString)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    func toggleTaskCompletion(_ task: Task) async throws -> Task {
        let newCompletionState = !task.isCompleted
        let taskUpdate = TaskUpdate(
            title: nil,
            description: nil,
            isCompleted: newCompletionState,
            priority: nil,
            categoryId: nil,
            dueDate: nil,
            dueTime: nil,
            completedAt: newCompletionState ? Date() : nil,
            sortOrder: nil
        )
        
        let response: Task = try await supabase
            .from("tasks")
            .update(taskUpdate)
            .eq("id", value: task.id.uuidString)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    // MARK: - Delete Task
    
    func deleteTask(_ task: Task) async throws {
        try await supabase
            .from("tasks")
            .delete()
            .eq("id", value: task.id.uuidString)
            .execute()
    }
}
