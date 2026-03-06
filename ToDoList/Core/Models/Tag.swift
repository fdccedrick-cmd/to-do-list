//
//  Tag.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation

struct Tag: Identifiable, Codable, Hashable {
    let id: UUID
    let userId: UUID
    var name: String
    var colorHex: String
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case colorHex = "color_hex"
        case createdAt = "created_at"
    }
}

// For creating new tags (without timestamp that DB generates)
struct TagInsert: Codable {
    let id: UUID
    let userId: UUID
    let name: String
    let colorHex: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case colorHex = "color_hex"
    }
}

// For updating tags
struct TagUpdate: Codable {
    let name: String
    let colorHex: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case colorHex = "color_hex"
    }
}
