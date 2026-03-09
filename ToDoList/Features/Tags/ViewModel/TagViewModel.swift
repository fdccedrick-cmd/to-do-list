//
//  TagViewModel.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation
import Combine
import SwiftUI

class TagViewModel: ObservableObject {
    @Published var tags: [Tag] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var showError = false
    
    private let tagRepository: TagRepositoryProtocol
    
    init(tagRepository: TagRepositoryProtocol = TagRepository()) {
        self.tagRepository = tagRepository
    }
    
    // MARK: - Fetch Tags
    
    @MainActor
    func fetchTags(for userId: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            tags = try await tagRepository.fetchTags(for: userId)
        } catch {
            errorMessage = "Failed to load tags: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Create Tag
    
    @MainActor
    func createTag(
        userId: UUID,
        name: String,
        colorHex: String
    ) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newTag = try await tagRepository.createTag(
                userId: userId,
                name: name,
                colorHex: colorHex
            )
            
            tags.append(newTag)
            tags.sort { $0.name < $1.name }
        } catch {
            errorMessage = "Failed to create tag: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Update Tag
    
    @MainActor
    func updateTag(_ tag: Tag) async {
        do {
            let updatedTag = try await tagRepository.updateTag(tag)
            
            if let index = tags.firstIndex(where: { $0.id == tag.id }) {
                tags[index] = updatedTag
            }
            
            tags.sort { $0.name < $1.name }
        } catch {
            errorMessage = "Failed to update tag: \(error.localizedDescription)"
            showError = true
        }
    }
    
    // MARK: - Delete Tag
    
    @MainActor
    func deleteTag(_ tag: Tag) async {
        do {
            try await tagRepository.deleteTag(tag)
            tags.removeAll { $0.id == tag.id }
        } catch {
            errorMessage = "Failed to delete tag: \(error.localizedDescription)"
            showError = true
        }
    }
}
