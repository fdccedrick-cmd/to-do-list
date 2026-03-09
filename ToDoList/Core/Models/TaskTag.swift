//
//  TaskTag.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation

struct TaskTag: Codable {
    let taskId: UUID
    let tagId: UUID
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case tagId = "tag_id"
        case createdAt = "created_at"
    }
}
struct TaskTagInsert: Codable {
    let taskId: UUID
    let tagId: UUID
    
    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case tagId = "tag_id"
    }
}
