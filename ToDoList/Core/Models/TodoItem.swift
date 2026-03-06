//
//  TodoItem.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation

struct TodoItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String?
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), title: String, description: String? = nil, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
