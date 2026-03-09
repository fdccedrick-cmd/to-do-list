//
//  CategoryRepository.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation

protocol CategoryRepositoryProtocol {
    func fetchCategories(for userId: UUID) async throws -> [Category]
    func createCategory(userId: UUID, name: String, icon: String, colorHex: String) async throws -> Category
    func updateCategory(_ category: Category) async throws -> Category
    func deleteCategory(_ category: Category) async throws
}

class CategoryRepository: CategoryRepositoryProtocol {
    private let categoryService: CategoryService
    
    init(categoryService: CategoryService = CategoryService()) {
        self.categoryService = categoryService
    }
    
    func fetchCategories(for userId: UUID) async throws -> [Category] {
        return try await categoryService.fetchCategories(for: userId)
    }
    
    func createCategory(
        userId: UUID,
        name: String,
        icon: String,
        colorHex: String
    ) async throws -> Category {
        return try await categoryService.createCategory(
            userId: userId,
            name: name,
            icon: icon,
            colorHex: colorHex
        )
    }
    
    func updateCategory(_ category: Category) async throws -> Category {
        return try await categoryService.updateCategory(category)
    }
    
    func deleteCategory(_ category: Category) async throws {
        try await categoryService.deleteCategory(category)
    }
}
