//
//  CategoryViewModel.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation
import Combine
import SwiftUI

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var showError = false
    
    private let categoryRepository: CategoryRepositoryProtocol
    
    init(categoryRepository: CategoryRepositoryProtocol = CategoryRepository()) {
        self.categoryRepository = categoryRepository
    }
    
    // MARK: - Fetch Categories
    
    @MainActor
    func fetchCategories(for userId: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            categories = try await categoryRepository.fetchCategories(for: userId)
        } catch {
            errorMessage = "Failed to load categories: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Create Category
    
    @MainActor
    func createCategory(
        userId: UUID,
        name: String,
        icon: String,
        colorHex: String
    ) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newCategory = try await categoryRepository.createCategory(
                userId: userId,
                name: name,
                icon: icon,
                colorHex: colorHex
            )
            
            categories.append(newCategory)
            categories.sort { $0.name < $1.name }
        } catch {
            errorMessage = "Failed to create category: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Update Category
    
    @MainActor
    func updateCategory(_ category: Category) async {
        do {
            let updatedCategory = try await categoryRepository.updateCategory(category)
            
            if let index = categories.firstIndex(where: { $0.id == category.id }) {
                categories[index] = updatedCategory
            }
            
            categories.sort { $0.name < $1.name }
        } catch {
            errorMessage = "Failed to update category: \(error.localizedDescription)"
            showError = true
        }
    }
    
    // MARK: - Delete Category
    
    @MainActor
    func deleteCategory(_ category: Category) async {
        do {
            try await categoryRepository.deleteCategory(category)
            categories.removeAll { $0.id == category.id }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
