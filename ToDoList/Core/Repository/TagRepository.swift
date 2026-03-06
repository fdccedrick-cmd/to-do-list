//
//  TagRepository.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation

/// Protocol defining tag data operations
protocol TagRepositoryProtocol {
    func fetchTags(for userId: UUID) async throws -> [Tag]
    func createTag(userId: UUID, name: String, colorHex: String) async throws -> Tag
    func updateTag(_ tag: Tag) async throws -> Tag
    func deleteTag(_ tag: Tag) async throws
    func addTagToTask(taskId: UUID, tagId: UUID) async throws
    func removeTagFromTask(taskId: UUID, tagId: UUID) async throws
    func fetchTagsForTask(taskId: UUID) async throws -> [Tag]
}

/// Concrete implementation of TagRepository using TagService
class TagRepository: TagRepositoryProtocol {
    private let tagService: TagService
    
    init(tagService: TagService = TagService()) {
        self.tagService = tagService
    }
    
    func fetchTags(for userId: UUID) async throws -> [Tag] {
        return try await tagService.fetchTags(for: userId)
    }
    
    func createTag(
        userId: UUID,
        name: String,
        colorHex: String
    ) async throws -> Tag {
        return try await tagService.createTag(
            userId: userId,
            name: name,
            colorHex: colorHex
        )
    }
    
    func updateTag(_ tag: Tag) async throws -> Tag {
        return try await tagService.updateTag(tag)
    }
    
    func deleteTag(_ tag: Tag) async throws {
        try await tagService.deleteTag(tag)
    }
    
    func addTagToTask(taskId: UUID, tagId: UUID) async throws {
        try await tagService.addTagToTask(taskId: taskId, tagId: tagId)
    }
    
    func removeTagFromTask(taskId: UUID, tagId: UUID) async throws {
        try await tagService.removeTagFromTask(taskId: taskId, tagId: tagId)
    }
    
    func fetchTagsForTask(taskId: UUID) async throws -> [Tag] {
        return try await tagService.fetchTagsForTask(taskId: taskId)
    }
}
