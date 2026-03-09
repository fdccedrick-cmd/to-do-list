//
//  TaskDetailView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI

struct TaskDetailView: View {
    let task: Task
    @ObservedObject var taskListViewModel: TaskListViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var reminders: [Reminder] = []
    @State private var deleteReminderAlert: Reminder?
    @State private var isAnimatingCompletion = false
    @State private var showCompletionCelebration = false
    
    private let reminderService = ReminderService()

    var body: some View {
        ZStack {
            Color(white: 0.96).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {

                    // MARK: - Task Info Card
                    VStack(alignment: .leading, spacing: 16) {
                        // Title + completion toggle
                        HStack(spacing: 12) {
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    isAnimatingCompletion = true
                                }
                                
                                // Haptic feedback
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                
                                _Concurrency.Task {
                                    await taskListViewModel.toggleTaskCompletion(task)
                                    
                                    // Show celebration if completed
                                    if task.isCompleted {
                                        await MainActor.run {
                                            withAnimation(.easeOut(duration: 0.4)) {
                                                showCompletionCelebration = true
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                withAnimation {
                                                    showCompletionCelebration = false
                                                }
                                            }
                                        }
                                    }
                                    
                                    await MainActor.run {
                                        withAnimation(.spring(response: 0.3)) {
                                            isAnimatingCompletion = false
                                        }
                                    }
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .stroke(
                                            task.isCompleted ? Color.black : Color(.systemGray4),
                                            lineWidth: 2
                                        )
                                        .frame(width: 28, height: 28)

                                    if task.isCompleted {
                                        Circle()
                                            .fill(Color.black)
                                            .frame(width: 28, height: 28)
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                            .scaleEffect(isAnimatingCompletion ? 1.2 : 1.0)
                                    }
                                }
                                .scaleEffect(isAnimatingCompletion ? 1.15 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimatingCompletion)
                            }
                            .buttonStyle(.plain)

                            Text(task.title)
                                .font(.system(size: 20, weight: .bold))
                                .strikethrough(task.isCompleted, color: .secondary)
                                .foregroundColor(task.isCompleted ? .secondary : .primary)
                                .animation(.easeInOut(duration: 0.3), value: task.isCompleted)
                        }

                        if !task.description.isEmpty {
                            Text(task.description)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }

                        Divider()

                        // Meta info
                        VStack(alignment: .leading, spacing: 12) {
                            // Priority + Due date row
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("PRIORITY")
                                        .font(.system(size: 9, weight: .bold))
                                        .tracking(1.5)
                                        .foregroundColor(.secondary)
                                    PriorityBadge(priority: task.priority)
                                }

                                if let dueDate = task.dueDate {
                                    Divider().frame(height: 30)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("DUE DATE")
                                            .font(.system(size: 9, weight: .bold))
                                            .tracking(1.5)
                                            .foregroundColor(.secondary)
                                        HStack(spacing: 4) {
                                            Image(systemName: "calendar")
                                                .font(.system(size: 11))
                                            Text(dueDate.formatted(.dateTime.month().day().year()))
                                                .font(.system(size: 12, weight: .medium))
                                        }
                                        .foregroundColor(
                                            dueDate < Date() && !task.isCompleted ? .red : .primary
                                        )
                                    }
                                }
                                Spacer()
                            }

                            // Category row
                            if let category = task.category {
                                Divider()
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("CATEGORY")
                                        .font(.system(size: 9, weight: .bold))
                                        .tracking(1.5)
                                        .foregroundColor(.secondary)

                                    HStack(spacing: 8) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(hex: category.colorHex).opacity(0.12))
                                                .frame(width: 32, height: 32)
                                            Text(category.icon)
                                                .font(.system(size: 16))
                                        }
                                        Text(category.name)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.primary)

                                        Circle()
                                            .fill(Color(hex: category.colorHex))
                                            .frame(width: 8, height: 8)
                                    }
                                }
                            }

                            // Tags row
                            if let tags = task.tags, !tags.isEmpty {
                                Divider()
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("TAGS")
                                        .font(.system(size: 9, weight: .bold))
                                        .tracking(1.5)
                                        .foregroundColor(.secondary)

                                    FlowLayout(spacing: 6) {
                                        ForEach(tags) { tag in
                                            HStack(spacing: 4) {
                                                Circle()
                                                    .fill(Color(hex: tag.colorHex))
                                                    .frame(width: 8, height: 8)
                                                Text(tag.name)
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.primary)
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color(hex: tag.colorHex).opacity(0.1))
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color(hex: tag.colorHex).opacity(0.3), lineWidth: 1)
                                            )
                                            .clipShape(Capsule())
                                        }
                                    }
                                }
                            }
                            
                            // Reminders row
                            if !reminders.isEmpty {
                                Divider()
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("REMINDERS")
                                        .font(.system(size: 9, weight: .bold))
                                        .tracking(1.5)
                                        .foregroundColor(.secondary)
                                    
                                    VStack(spacing: 6) {
                                        ForEach(reminders) { reminder in
                                            HStack(spacing: 8) {
                                                Image(systemName: reminder.isSent ? "bell.fill" : "bell")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(reminder.isSent ? .gray : .orange)
                                                
                                                Text(reminder.remindAt.formatted(date: .abbreviated, time: .shortened))
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.primary)
                                                
                                                Spacer()
                                                
                                                Button {
                                                    deleteReminderAlert = reminder
                                                } label: {
                                                    Image(systemName: "trash")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.red.opacity(0.7))
                                                }
                                                .buttonStyle(.plain)
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(18)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)

                    // MARK: - Subtasks 
                    SubtaskListView(taskId: task.id)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            
            // MARK: - Completion Celebration Overlay
            if showCompletionCelebration {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                        Text("Task Completed!")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    )
                    .padding(.bottom, 80)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(100)
            }
        }
        .task {
            await loadReminders()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("TASK DETAIL")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(3)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showEditSheet = true
                    } label: {
                        Label("Edit Task", systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete Task", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 18))
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditTaskView(viewModel: taskListViewModel, task: task)
        }
        .alert("Delete Task", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                _Concurrency.Task {
                    await taskListViewModel.deleteTask(task)
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete '\(task.title)'? This action cannot be undone.")
        }
        .alert("Delete Reminder", isPresented: .constant(deleteReminderAlert != nil), presenting: deleteReminderAlert) { reminder in
            Button("Cancel", role: .cancel) {
                deleteReminderAlert = nil
            }
            Button("Delete", role: .destructive) {
                _Concurrency.Task {
                    await deleteReminder(reminder)
                }
            }
        } message: { reminder in
            Text("Are you sure you want to delete this reminder for \(reminder.remindAt.formatted(date: .abbreviated, time: .shortened))?")
        }
    }
    
    // MARK: - Helper Functions
    private func loadReminders() async {
        do {
            reminders = try await reminderService.fetchReminders(for: task.id)
        } catch {
            print("Error loading reminders: \(error)")
        }
    }
    
    @MainActor
    private func deleteReminder(_ reminder: Reminder) async {
        do {
            try await reminderService.deleteReminder(reminder)
            reminders.removeAll { $0.id == reminder.id }
            deleteReminderAlert = nil
        } catch {
            print("Error deleting reminder: \(error)")
        }
    }
}
