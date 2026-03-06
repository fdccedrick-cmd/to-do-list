//
//  Reminder.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation

struct Reminder: Identifiable, Codable {
    let id: UUID
    let taskId: UUID
    let userId: UUID
    var remindAt: Date
    var isSent: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case taskId = "task_id"
        case userId = "user_id"
        case remindAt = "remind_at"
        case isSent = "is_sent"
        case createdAt = "created_at"
    }
}
