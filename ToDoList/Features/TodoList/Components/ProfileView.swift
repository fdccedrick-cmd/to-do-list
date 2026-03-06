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
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authService.currentUser?.email ?? "User")
                                .font(.headline)
                            
                            Text("Member since \(Date().formatted(.dateTime.year()))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Organization") {
                    Button(action: { showCategoryManagement = true }) {
                        Label("Categories", systemImage: "folder.fill")
                            .foregroundStyle(.primary)
                    }
                    
                    Button(action: { showTagManagement = true }) {
                        Label("Tags", systemImage: "tag.fill")
                            .foregroundStyle(.primary)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        _Concurrency.Task {
                            try? await authService.signOut()
                            dismiss()
                        }
                    } label: {
                        Label("Sign Out", systemImage: "arrow.right.square")
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showCategoryManagement) {
                CategoryManagementView()
            }
            .sheet(isPresented: $showTagManagement) {
                TagManagementView()
            }
        }
    }
}
