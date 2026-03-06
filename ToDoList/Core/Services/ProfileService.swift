//
//  ProfileService.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation
import Supabase

class ProfileService {
    private let supabase = SupabaseManager.shared.client

    func fetchProfile(for userId: UUID) async throws -> Profile {
        let response: Profile = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value

        return response
    }

    func updateProfile(_ profile: Profile) async throws -> Profile {
        let response: Profile = try await supabase
            .from("profiles")
            .update(profile)
            .eq("id", value: profile.id.uuidString)
            .select()
            .single()
            .execute()
            .value

        return response
    }
}
