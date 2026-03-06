//
//  Profile.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation

struct Profile: Identifiable, Codable {
    let id: UUID
    var displayName: String
    var avatarUrl: String?
    var timezone: String
    let createdAt: Date?
    var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case timezone
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// For creating new profiles (without timestamp fields that DB generates)
struct ProfileInsert: Codable {
    let id: UUID
    let displayName: String
    let timezone: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case timezone
    }
}
