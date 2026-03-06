//
//  TagService.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation
import Supabase

class TagService {
    private let supabase = SupabaseManager.shared.client
    
    // MARK: - Fetch Tags
    
    func fetchTags(for userId: UUID) async throws -> [Tag] {
        let response: [Tag] = try await supabase
            .from("tags")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("name", ascending: true)
            .execute()
            .value
        
        return response
    }
    
    // MARK: - Create Tag
    
    func createTag(
        userId: UUID,
        name: String,
        colorHex: String
    ) async throws -> Tag {
        let tagInsert = TagInsert(
            id: UUID(),
            userId: userId,
            name: name,
            colorHex: colorHex
        )
        
        let response: Tag = try await supabase
            .from("tags")
            .insert(tagInsert)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    // MARK: - Update Tag
    
    func updateTag(_ tag: Tag) async throws -> Tag {
        let tagUpdate = TagUpdate(
            name: tag.name,
            colorHex: tag.colorHex
        )
        
        let response: Tag = try await supabase
            .from("tags")
            .update(tagUpdate)
            .eq("id", value: tag.id.uuidString)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    // MARK: - Delete Tag
    
    func deleteTag(_ tag: Tag) async throws {
        try await supabase
            .from("tags")
            .delete()
            .eq("id", value: tag.id.uuidString)
            .execute()
    }
    
    // MARK: - Task-Tag Relationship
    
    func addTagToTask(taskId: UUID, tagId: UUID) async throws {
        let taskTagInsert = TaskTagInsert(
            taskId: taskId,
            tagId: tagId
        )
        
        try await supabase
            .from("task_tags")
            .insert(taskTagInsert)
            .execute()
    }
    
    func removeTagFromTask(taskId: UUID, tagId: UUID) async throws {
        try await supabase
            .from("task_tags")
            .delete()
            .eq("task_id", value: taskId.uuidString)
            .eq("tag_id", value: tagId.uuidString)
            .execute()
    }
    
    func fetchTagsForTask(taskId: UUID) async throws -> [Tag] {
        // TODO: Implement join query when needed
        // For now, return empty array - requires proper join handling with Supabase
        return []
    }
}
