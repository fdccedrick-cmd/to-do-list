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

            // MARK: - Priority Border (flush to card edge)
            RoundedRectangle(cornerRadius: 3)
                .fill(task.isCompleted ? Color(.systemGray4) : priorityColor)
                .frame(width: 4)
                .padding(.vertical, 0) // ✅ full height, no gap

            // MARK: - Checkbox
            Button(action: {
                _Concurrency.Task {
                    await viewModel.toggleTaskCompletion(task) // ✅ unchanged
                }
            }) {
                ZStack {
                    Circle()
                        .stroke(
                            task.isCompleted ? Color(.systemGray4) : priorityColor,
                            lineWidth: 1.5
                        )
                        .frame(width: 22, height: 22)

                    if task.isCompleted {
                        Circle()
                            .fill(Color(.systemGray4))
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.leading, 14)
            .padding(.trailing, 12)

            // MARK: - Content
            VStack(alignment: .leading, spacing: 5) {

                // Title + chevron row
                HStack(alignment: .center) {
                    Text(task.title)
                        .font(.system(size: 14, weight: task.isCompleted ? .regular : .semibold))
                        .strikethrough(task.isCompleted, color: Color(.systemGray3))
                        .foregroundColor(task.isCompleted ? Color(.systemGray3) : .primary)
                        .lineLimit(1)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(.systemGray4))
                        .padding(.trailing, 14)
                }

                // Description
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                // MARK: - Badges Row
                if !task.isCompleted {
                    HStack(spacing: 5) {

                        // Category
                        if let category = task.category {
                            HStack(spacing: 3) {
                                Text(category.icon)
                                    .font(.system(size: 9))
                                Text(category.name)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(Color(hex: category.colorHex))
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color(hex: category.colorHex).opacity(0.1))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color(hex: category.colorHex).opacity(0.2), lineWidth: 1)
                            )
                        }

                        // Priority badge
                        PriorityBadge(priority: task.priority) // ✅ unchanged

                        // Due date
                        if let dueDate = task.dueDate {
                            let isOverdue = dueDate < Date() && !task.isCompleted
                            HStack(spacing: 3) {
                                Image(systemName: isOverdue ? "calendar.badge.exclamationmark" : "calendar")
                                    .font(.system(size: 9))
                                Text(dueDate.formatted(.dateTime.month().day()))
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(isOverdue ? .red : Color(.systemGray2))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(isOverdue ? Color.red.opacity(0.07) : Color(.systemGray6))
                            .clipShape(Capsule())
                        }
                    }
                } else {
                    // Completed — show minimal category only
                    if let category = task.category {
                        HStack(spacing: 3) {
                            Text(category.icon)
                                .font(.system(size: 9))
                            Text(category.name)
                                .font(.system(size: 10))
                                .foregroundColor(Color(.systemGray3))
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                    }
                }

                // MARK: - Tags Row
                if let tags = task.tags, !tags.isEmpty, !task.isCompleted {
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
                                .background(Color(hex: tag.colorHex).opacity(0.08))
                                .clipShape(Capsule())
                            }
                        }
                    }
                }

                // MARK: - Subtask Progress
                if subtaskViewModel.totalCount > 0 {
                    HStack(spacing: 6) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 3)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(
                                        subtaskViewModel.allCompleted
                                            ? Color(.systemGray4)
                                            : priorityColor.opacity(0.6)
                                    )
                                    .frame(
                                        width: geo.size.width * subtaskViewModel.progress,
                                        height: 3
                                    )
                                    .animation(.spring(response: 0.4), value: subtaskViewModel.progress)
                            }
                        }
                        .frame(width: 56, height: 3)

                        Text(subtaskViewModel.progressText)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(subtaskViewModel.allCompleted ? Color(.systemGray3) : .secondary)

                        if subtaskViewModel.allCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color(.systemGray3))
                        }
                    }
                }
            }
            .padding(.vertical, 14)
        }
        // ✅ Card background per completion state
        .background(
            task.isCompleted
                ? Color(.systemGray6).opacity(0.6)
                : Color.white
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(
            color: task.isCompleted
                ? Color.clear
                : Color.black.opacity(0.05),
            radius: 6, x: 0, y: 2
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    task.isCompleted
                        ? Color(.systemGray5)
                        : Color.clear,
                    lineWidth: 1
                )
        )
        .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
        // ✅ unchanged swipe + alert
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
                    await viewModel.deleteTask(task) // ✅ unchanged
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
