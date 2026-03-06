//
//  Category.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation

struct Category: Identifiable, Codable {
    let id: UUID
    let userId: UUID?
    var name: String
    var icon: String
    var colorHex: String
    var isDefault: Bool
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case icon
        case colorHex = "color_hex"
        case isDefault = "is_default"
        case createdAt = "created_at"
    }
}

// For creating new categories (without timestamp that DB generates)
struct CategoryInsert: Codable {
    let id: UUID
    let userId: UUID
    let name: String
    let icon: String
    let colorHex: String
    let isDefault: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case icon
        case colorHex = "color_hex"
        case isDefault = "is_default"
    }
}

// For updating categories
struct CategoryUpdate: Codable {
    let name: String
    let icon: String
    let colorHex: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case icon
        case colorHex = "color_hex"
    }
}
