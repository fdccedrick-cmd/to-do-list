//
//  TaskAttachment.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation

struct TaskAttachment: Identifiable, Codable {
    let id: UUID
    let taskId: UUID
    let userId: UUID
    var fileName: String
    var fileSize: Int
    var mimeType: String
    var storagePath: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case taskId = "task_id"
        case userId = "user_id"
        case fileName = "file_name"
        case fileSize = "file_size"
        case mimeType = "mime_type"
        case storagePath = "storage_path"
        case createdAt = "created_at"
    }
}
