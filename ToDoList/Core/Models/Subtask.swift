//
//  Subtask.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation

struct Subtask: Identifiable, Codable {
    let id: UUID
    let taskId: UUID
    var title: String
    var isCompleted: Bool
    var sortOrder: Int
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case taskId = "task_id"
        case title
        case isCompleted = "is_completed"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
