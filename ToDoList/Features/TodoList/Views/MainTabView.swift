//
//  MainTabView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI
import Auth

struct MainTabView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = TaskListViewModel()
    
    var body: some View {
        TabView {
            // Dashboard Tab
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .badge(viewModel.overdueTasks.count > 0 ? viewModel.overdueTasks.count : 0)
            
            // All Tasks Tab
            AllTasksView()
                .tabItem {
                    Label("Tasks", systemImage: "checkmark.circle.fill")
                }
            
            // Categories Tab
            CategoryManagementView()
                .tabItem {
                    Label("Categories", systemImage: "folder.fill")
                }
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .task {
            guard let userId = authService.currentUser?.id else { return }
            await viewModel.loadDashboard(for: userId)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthService())
}
