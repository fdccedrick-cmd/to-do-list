//
//  ProfileView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI
import Auth

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss        
    @EnvironmentObject var authService: AuthService 

    @State private var showCategoryManagement = false 
    @State private var showTagManagement = false   
    @State private var profile: Profile?
    @State private var isLoadingProfile = false
    
    private let profileService = ProfileService()   

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.96).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // MARK: - Avatar Card
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 80, height: 80)
                                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)

                                Image(systemName: "person.fill")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(.white)
                            }

                            VStack(spacing: 4) {
                                Text(profile?.displayName ?? authService.currentUser?.email?.components(separatedBy: "@").first ?? "User")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                                Text(authService.currentUser?.email ?? "User")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)

                                Text("Member since \(Date().formatted(.dateTime.year()))")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 28)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)

                        // MARK: - Organization Card
                        VStack(alignment: .leading, spacing: 0) {
                            Text("ORGANIZATION")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(2)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 18)
                                .padding(.top, 16)
                                .padding(.bottom, 10)

                            settingsRow(
                                icon: "folder.fill",
                                label: "Categories",
                                action: { showCategoryManagement = true }
                            )

                            Divider().padding(.leading, 56)

                            settingsRow(
                                icon: "tag.fill",
                                label: "Tags",
                                action: { showTagManagement = true }
                            )
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)

                        // MARK: - Sign Out
                        Button {
                            _Concurrency.Task {
                                try? await authService.signOut()
                                dismiss()
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.right.square")
                                    .font(.system(size: 16))
                                Text("Sign Out")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.red.opacity(0.15), lineWidth: 1)
                            )
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("PROFILE")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(3)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                }
            }
            .sheet(isPresented: $showCategoryManagement) {
                CategoryManagementView()
            }
            .sheet(isPresented: $showTagManagement) {
                TagManagementView()
            }
            .task {
                guard let userId = authService.currentUser?.id else { return }
                isLoadingProfile = true
                do {
                    profile = try await profileService.fetchProfile(for: userId)
                } catch {
                    print("Failed to load profile: \(error)")
                }
                isLoadingProfile = false
            }
        }
    }

    private func settingsRow(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }

                Text(label)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(.systemGray4))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
    }
}
