//
//  DashboardView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI
import Auth

struct DashboardView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = TaskListViewModel()
    
    @State private var showAddTask = false
    @State private var showProfile = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.tasks.isEmpty {
                    // Loading state
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading your tasks...")
                            .foregroundStyle(.secondary)
                    }
                } else if viewModel.tasks.isEmpty {
                    // Empty state
                    EmptyStateView(onAddTask: { showAddTask = true })
                } else {
                    // Task list
                    TaskListContent(viewModel: viewModel)
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(viewModel: viewModel, userId: authService.currentUser?.id ?? UUID())
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .task {
                if let userId = authService.currentUser?.id {
                    await viewModel.fetchTasks(for: userId)
                }
            }
            .refreshable {
                if let userId = authService.currentUser?.id {
                    await viewModel.refreshTasks(for: userId)
                }
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthService())
}

