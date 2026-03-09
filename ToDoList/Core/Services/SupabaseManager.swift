//
//  SupabaseManager.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation
import Supabase

/// Singleton manager for Supabase client
class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        guard let supabaseURL = URL(string: SupabaseConfig.supabaseURL) else {
            fatalError("Invalid Supabase URL in SupabaseConfig")
        }
        
        let supabaseKey = SupabaseConfig.supabaseAnonKey
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey,
            options: SupabaseClientOptions(
                db: SupabaseClientOptions.DatabaseOptions(
                    encoder: encoder,
                    decoder: decoder
                )
            )
        )
    }
}
