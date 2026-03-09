//
//  TaskRowView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI

struct TaskRowView: View {
    let task: Task
    @ObservedObject var viewModel: TaskListViewModel
    @StateObject private var subtaskViewModel: SubtaskViewModel

    @State private var showDeleteAlert = false

    init(task: Task, viewModel: TaskListViewModel) {
        self.task = task
        self.viewModel = viewModel
        _subtaskViewModel = StateObject(
            wrappedValue: SubtaskViewModel(taskId: task.id)
        )
    }

    var body: some View {
        HStack(spacing: 0) {

            // MARK: - Priority Border
            Rectangle()
                .fill(priorityColor)
                .frame(width: 4)
                .clipShape(
                    RoundedRectangle(cornerRadius: 2)
                )
                .padding(.vertical, 12)

            // MARK: - Checkbox
            Button(action: {
                _Concurrency.Task {
                    await viewModel.toggleTaskCompletion(task)
                }
            }) {
                ZStack {
                    Circle()
                        .stroke(
                            task.isCompleted ? Color.black : Color(.systemGray4),
                            lineWidth: 1.5
                        )
                        .frame(width: 22, height: 22)

                    if task.isCompleted {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 14)

            // MARK: - Content
            VStack(alignment: .leading, spacing: 6) {

                // Title
                Text(task.title)
                    .font(.system(size: 15, weight: .semibold))
                    .strikethrough(task.isCompleted, color: Color(.systemGray3))
                    .foregroundColor(task.isCompleted ? Color(.systemGray3) : .primary)
                    .lineLimit(1)

                // Description
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                // MARK: - Badges Row
                HStack(spacing: 6) {

                    // Category
                    if let category = task.category {
                        HStack(spacing: 4) {
                            Text(category.icon)
                                .font(.system(size: 10))
                            Text(category.name)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color(hex: category.colorHex))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: category.colorHex).opacity(0.1))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color(hex: category.colorHex).opacity(0.25), lineWidth: 1)
                        )
                    }

                    // Priority
                    PriorityBadge(priority: task.priority)

                    // Due date
                    if let dueDate = task.dueDate {
                        let isOverdue = dueDate < Date() && !task.isCompleted
                        HStack(spacing: 3) {
                            Image(systemName: isOverdue ? "calendar.badge.exclamationmark" : "calendar")
                                .font(.system(size: 10))
                            Text(dueDate.formatted(.dateTime.month().day()))
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(isOverdue ? .red : .secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(isOverdue ? Color.red.opacity(0.08) : Color(.systemGray6))
                        .clipShape(Capsule())
                    }
                }

                // MARK: - Tags Row
                if let tags = task.tags, !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(tags) { tag in
                                HStack(spacing: 3) {
                                    Circle()
                                        .fill(Color(hex: tag.colorHex))
                                        .frame(width: 5, height: 5)
                                    Text(tag.name)
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Color(.systemGray6))
                                .clipShape(Capsule())
                            }
                        }
                    }
                }

                // MARK: - Subtask Progress
                if subtaskViewModel.totalCount > 0 {
                    HStack(spacing: 6) {
                        // Mini progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 3)

                                RoundedRectangle(cornerRadius: 2)
                                    .fill(
                                        subtaskViewModel.allCompleted
                                            ? Color.black
                                            : priorityColor.opacity(0.7)
                                    )
                                    .frame(
                                        width: geo.size.width * subtaskViewModel.progress,
                                        height: 3
                                    )
                                    .animation(.spring(response: 0.4), value: subtaskViewModel.progress)
                            }
                        }
                        .frame(width: 60, height: 3)

                        Text(subtaskViewModel.progressText)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(
                                subtaskViewModel.allCompleted ? .black : .secondary
                            )

                        if subtaskViewModel.allCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.black)
                        }
                    }
                }
            }

            Spacer(minLength: 8)

            // MARK: - Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(.systemGray4))
                .padding(.trailing, 16)
        }
        .padding(.vertical, 14)
        .background(
            task.isCompleted
                ? Color(.systemGray6).opacity(0.5)
                : Color.white
        )
        .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete Task", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                _Concurrency.Task {
                    await viewModel.deleteTask(task)
                }
            }
        } message: {
            Text("Are you sure you want to delete '\(task.title)'?")
        }
        .task {
            await subtaskViewModel.fetchSubtasks()
        }
    }

    private var priorityColor: Color {
        switch task.priority {
        case .urgent: return .red
        case .high:   return .orange
        case .medium: return Color(hex: "F59E0B")
        case .low:    return .green
        }
    }
}
