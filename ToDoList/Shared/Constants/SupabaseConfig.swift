//
//  SupabaseConfig.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation

enum SupabaseConfig {
    /// Your Supabase project URL
    /// Get this from: https://app.supabase.com/project/_/settings/api
    static let supabaseURL = "YOUR_SUPABASE_URL"
    
    /// Your Supabase anon/public key
    /// Get this from: https://app.supabase.com/project/_/settings/api
    static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
    
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
