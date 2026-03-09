//
//  ReminderListView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/9/26.
//

import SwiftUI
import Auth

struct ReminderListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = ReminderViewModel()
    
    @State private var showAddReminder = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.96).ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.reminders.isEmpty {
                    loadingView
                } else if viewModel.reminders.isEmpty {
                    emptyStateView
                } else {
                    remindersList
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("REMINDERS")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(3)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                }
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
                    await viewModel.fetchAllReminders(for: userId)
                }
            }
        }
    }
    
    private var remindersList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Upcoming Reminders
                if !viewModel.upcomingReminders.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("UPCOMING")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 18)
                        
                        VStack(spacing: 0) {
                            ForEach(Array(viewModel.upcomingReminders.enumerated()), id: \.element.id) { index, reminder in
                                ReminderRow(reminder: reminder, viewModel: viewModel)
                                
                                if index < viewModel.upcomingReminders.count - 1 {
                                    Divider()
                                        .padding(.leading, 18)
                                }
                            }
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    }
                }
                
                // Past Reminders
                if !viewModel.pastReminders.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PAST")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 18)
                        
                        VStack(spacing: 0) {
                            ForEach(Array(viewModel.pastReminders.enumerated()), id: \.element.id) { index, reminder in
                                ReminderRow(reminder: reminder, viewModel: viewModel)
                                    .opacity(0.6)
                                
                                if index < viewModel.pastReminders.count - 1 {
                                    Divider()
                                        .padding(.leading, 18)
                                }
                            }
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    }
                }
                
                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.black)
            Text("Loading reminders...")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                
                Image(systemName: "bell.slash")
                    .font(.system(size: 32))
                    .foregroundColor(.secondary)
            }
            
            Text("No Reminders")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Add reminders from your tasks to get notified")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

// MARK: - Reminder Row

struct ReminderRow: View {
    let reminder: Reminder
    @ObservedObject var viewModel: ReminderViewModel
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        HStack(spacing: 14) {
            // Bell Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(reminder.remindAt > Date() ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    .frame(width: 40, height: 40)
                
                Image(systemName: reminder.remindAt > Date() ? "bell.fill" : "bell.slash.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(reminder.remindAt > Date() ? .blue : .secondary)
            }
            
            // Reminder Info
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.remindAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Task ID: \(reminder.taskId.uuidString.prefix(8))...")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Delete Button
            Button {
                showDeleteConfirmation = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .confirmationDialog("Delete Reminder", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                _Concurrency.Task {
                    await viewModel.deleteReminder(reminder)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this reminder?")
        }
    }
}

#Preview {
    ReminderListView()
        .environmentObject(AuthService())
}
