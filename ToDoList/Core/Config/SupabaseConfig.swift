//
//  SupabaseConfig.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation

enum SupabaseConfig {
    /// Your Supabase project URL
    /// Loaded from SupabaseSecrets.swift (gitignored)
    static let supabaseURL = SupabaseSecrets.url

    static let supabaseAnonKey = SupabaseSecrets.anonKey
    
    /// Table names
    enum Tables {
        static let profiles = "profiles"
        static let categories = "categories"
        static let tasks = "tasks"
        static let tags = "tags"
        static let taskTags = "task_tags"
        static let subtasks = "subtasks"
        static let taskAttachments = "task_attachments"
        static let reminders = "reminders"
    }
}
