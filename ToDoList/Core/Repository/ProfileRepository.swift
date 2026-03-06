//
//  ProfileRepository.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation

protocol ProfileRepositoryProtocol {
    func fetchProfile(for userId: UUID) async throws -> Profile
    func updateProfile(_ profile: Profile) async throws -> Profile
}

class ProfileRepository: ProfileRepositoryProtocol {
    private let profileService: ProfileService

    init(profileService: ProfileService = ProfileService()) {
        self.profileService = profileService
    }

    func fetchProfile(for userId: UUID) async throws -> Profile {
        return try await profileService.fetchProfile(for: userId)
    }

    func updateProfile(_ profile: Profile) async throws -> Profile {
        return try await profileService.updateProfile(profile)
    }
}
