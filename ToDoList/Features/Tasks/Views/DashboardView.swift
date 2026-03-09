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
                Color(white: 0.96).ignoresSafeArea()

                if viewModel.isLoading && viewModel.tasks.isEmpty {
                    loadingView
                } else if viewModel.tasks.isEmpty {
                    EmptyStateView(onAddTask: { showAddTask = true })
                } else {
                    TaskListContent(viewModel: viewModel)
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        addButton
                            .padding(.trailing, 24)
                            .padding(.bottom, 32)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showProfile = true } label: {
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 32, height: 32)

                                if let name = viewModel.profile?.displayName,
                                   let first = name.first {
                                    Text(String(first).uppercased())
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                }
                            }

                            VStack(alignment: .leading, spacing: 1) {
                                Text("Hello,")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Text(viewModel.profile?.displayName ?? "there")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("MY TASKS")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(3)
                        .foregroundColor(.primary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 4) {
                        Text("\(viewModel.incompleteTasks.count)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(Color.black)
                            .clipShape(Circle())
                        Text("left")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
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
                guard let userId = authService.currentUser?.id else { return }
                await viewModel.loadDashboard(for: userId)
            }
            .refreshable {
                guard let userId = authService.currentUser?.id else { return }
                await viewModel.refreshTasks(for: userId)
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 72, height: 72)
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.black)
            }
            Text("Loading your tasks...")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }

    private var addButton: some View {
        Button { showAddTask = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                Text("New Task")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.black)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthService())
}
