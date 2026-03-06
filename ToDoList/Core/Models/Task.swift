//
//  Task.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation

enum TaskPriority: String, Codable, CaseIterable {
    case low
    case medium
    case high
    case urgent
    
    var displayName: String {
        rawValue.capitalized
    }
}

// Date formatter for PostgreSQL date type (YYYY-MM-DD)
fileprivate let dateOnlyFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone(identifier: "UTC")
    return formatter
}()

struct Task: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    var categoryId: UUID?
    var title: String
    var description: String
    var isCompleted: Bool
    var priority: TaskPriority
    var dueDate: Date?
    var dueTime: String?
    var completedAt: Date?
    var sortOrder: Int
    let createdAt: Date
    var updatedAt: Date
    
    // Related data (not in database, loaded separately)
    var category: Category?
    var tags: [Tag]?
    var subtasks: [Subtask]?
    var attachments: [TaskAttachment]?
    var reminders: [Reminder]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case categoryId = "category_id"
        case title
        case description
        case isCompleted = "is_completed"
        case priority
        case dueDate = "due_date"
        case dueTime = "due_time"
        case completedAt = "completed_at"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Regular initializer
    init(
        id: UUID,
        userId: UUID,
        categoryId: UUID? = nil,
        title: String,
        description: String = "",
        isCompleted: Bool = false,
        priority: TaskPriority = .medium,
        dueDate: Date? = nil,
        dueTime: String? = nil,
        completedAt: Date? = nil,
        sortOrder: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.categoryId = categoryId
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.priority = priority
        self.dueDate = dueDate
        self.dueTime = dueTime
        self.completedAt = completedAt
        self.sortOrder = sortOrder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        categoryId = try container.decodeIfPresent(UUID.self, forKey: .categoryId)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        priority = try container.decode(TaskPriority.self, forKey: .priority)
        
        // Handle due_date as string (PostgreSQL date type)
        if let dueDateString = try container.decodeIfPresent(String.self, forKey: .dueDate) {
            dueDate = dateOnlyFormatter.date(from: dueDateString)
        } else {
            dueDate = nil
        }
        
        dueTime = try container.decodeIfPresent(String.self, forKey: .dueTime)
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
        sortOrder = try container.decode(Int.self, forKey: .sortOrder)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}

// For creating new tasks (without timestamp that DB generates)
struct TaskInsert: Encodable {
    let id: UUID
    let userId: UUID
    let categoryId: UUID?
    let title: String
    let description: String
    let isCompleted: Bool
    let priority: TaskPriority
    let dueDate: Date?
    let dueTime: String?
    let sortOrder: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case categoryId = "category_id"
        case title
        case description
        case isCompleted = "is_completed"
        case priority
        case dueDate = "due_date"
        case dueTime = "due_time"
        case sortOrder = "sort_order"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encodeIfPresent(categoryId, forKey: .categoryId)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(priority, forKey: .priority)
        
        // Encode due_date as string (PostgreSQL date type)
        if let date = dueDate {
            try container.encode(dateOnlyFormatter.string(from: date), forKey: .dueDate)
        }
        
        try container.encodeIfPresent(dueTime, forKey: .dueTime)
        try container.encode(sortOrder, forKey: .sortOrder)
    }
}

// For updating tasks
struct TaskUpdate: Encodable {
    let title: String?
    let description: String?
    let isCompleted: Bool?
    let priority: TaskPriority?
    let categoryId: UUID?
    let dueDate: Date?
    let dueTime: String?
    let completedAt: Date?
    let sortOrder: Int?
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case isCompleted = "is_completed"
        case priority
        case categoryId = "category_id"
        case dueDate = "due_date"
        case dueTime = "due_time"
        case completedAt = "completed_at"
        case sortOrder = "sort_order"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(isCompleted, forKey: .isCompleted)
        try container.encodeIfPresent(priority, forKey: .priority)
        try container.encodeIfPresent(categoryId, forKey: .categoryId)
        
        // Encode due_date as string (PostgreSQL date type)
        if let date = dueDate {
            try container.encode(dateOnlyFormatter.string(from: date), forKey: .dueDate)
        }
        
        try container.encodeIfPresent(dueTime, forKey: .dueTime)
        try container.encodeIfPresent(completedAt, forKey: .completedAt)
        try container.encodeIfPresent(sortOrder, forKey: .sortOrder)
    }
}
