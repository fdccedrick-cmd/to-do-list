//
//  CategoryService.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation
import Supabase

class CategoryService {
    private let supabase = SupabaseManager.shared.client
    
    // MARK: - Fetch Categories
    func fetchCategories(for userId: UUID) async throws -> [Category] {
        let response: [Category] = try await supabase
            .from("categories")
            .select()
            .or("user_id.eq.\(userId.uuidString),is_default.eq.true")
            .order("name", ascending: true)
            .execute()
            .value
        
        return response
    }
    
    // MARK: - Create Category
    func createCategory(
        userId: UUID,
        name: String,
        icon: String,
        colorHex: String
    ) async throws -> Category {
        let categoryInsert = CategoryInsert(
            id: UUID(),
            userId: userId,
            name: name,
            icon: icon,
            colorHex: colorHex,
            isDefault: false
        )
        
        let response: Category = try await supabase
            .from("categories")
            .insert(categoryInsert)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    // MARK: - Update Category
    func updateCategory(_ category: Category) async throws -> Category {
        let categoryUpdate = CategoryUpdate(
            name: category.name,
            icon: category.icon,
            colorHex: category.colorHex
        )
        
        let response: Category = try await supabase
            .from("categories")
            .update(categoryUpdate)
            .eq("id", value: category.id.uuidString)
            .select()
            .single()
            .execute()
            .value
        
        return response
    }
    
    // MARK: - Delete Category
    func deleteCategory(_ category: Category) async throws {
        guard !category.isDefault else {
            throw NSError(domain: "CategoryService", code: 403, userInfo: [
                NSLocalizedDescriptionKey: "Cannot delete default categories"
            ])
        }
        
        try await supabase
            .from("categories")
            .delete()
            .eq("id", value: category.id.uuidString)
            .execute()
    }
}
