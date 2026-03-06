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
        guard let supabaseURL = URL(string: "https://lqrfyyyqwjoyddpkctpf.supabase.co") else {
            fatalError("Invalid Supabase URL")
        }
        
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxxcmZ5eXlxd2pveWRkcGtjdHBmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3NTk5NzMsImV4cCI6MjA4ODMzNTk3M30.8OdqctBYstofM9huTObnzdVb03M_JjzkmXSqQGeGYbg"
        
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
