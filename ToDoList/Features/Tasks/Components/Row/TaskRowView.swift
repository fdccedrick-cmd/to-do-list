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

    private let purple = Color(red: 0.42, green: 0.35, blue: 0.95)

    init(task: Task, viewModel: TaskListViewModel) {
        self.task = task
        self.viewModel = viewModel
        _subtaskViewModel = StateObject(
            wrappedValue: SubtaskViewModel(taskId: task.id)
        )
    }

    var body: some View {
        HStack(spacing: 0) {

            // MARK: - Priority accent bar
            RoundedRectangle(cornerRadius: 3)
                .fill(task.isCompleted ? Color(.systemGray5) : priorityColor)
                .frame(width: 5)

            HStack(alignment: .top, spacing: 14) {

                // MARK: - Category icon bubble + checkbox
                VStack(spacing: 10) {
                    // Category icon bubble
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(categoryBgColor)
                            .frame(width: 46, height: 46)
                        if let category = task.category {
                            Text(category.icon)
                                .font(.system(size: 22))
                        } else {
                            Image(systemName: "checklist")
                                .font(.system(size: 18))
                                .foregroundColor(purple.opacity(0.5))
                        }
                    }

                    // Checkbox below icon
                    Button {
                        _Concurrency.Task {
                            await viewModel.toggleTaskCompletion(task) // ✅ unchanged
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(
                                    task.isCompleted
                                        ? Color(hex: "10B981")
                                        : Color(.systemGray4),
                                    lineWidth: 2
                                )
                                .frame(width: 24, height: 24)
                            if task.isCompleted {
                                Circle()
                                    .fill(Color(hex: "10B981"))
                                    .frame(width: 24, height: 24)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.leading, 16)

                // MARK: - Main content
                VStack(alignment: .leading, spacing: 8) {

                    // Category label + chevron
                    HStack {
                        if let category = task.category {
                            Text(category.name.uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1.2)
                                .foregroundColor(
                                    task.isCompleted
                                        ? Color(.systemGray3)
                                        : Color(hex: category.colorHex)
                                )
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(.systemGray4))
                    }

                    // Title
                    Text(task.title)
                        .font(.system(size: 16, weight: task.isCompleted ? .regular : .bold))
                        .strikethrough(task.isCompleted, color: Color(.systemGray3))
                        .foregroundColor(task.isCompleted ? Color(.systemGray3) : .primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    // Description
                    if !task.description.isEmpty {
                        Text(task.description)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // MARK: - Badges (hidden when completed)
                    if !task.isCompleted {
                        HStack(spacing: 6) {
                            // Priority badge
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(priorityColor)
                                    .frame(width: 6, height: 6)
                                Text(task.priority.displayName)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(priorityColor)
                            }
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(priorityColor.opacity(0.1))
                            .clipShape(Capsule())

                            // Due date
                            if let dueDate = task.dueDate {
                                let isOverdue = dueDate < Date() && !task.isCompleted
                                HStack(spacing: 4) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 10))
                                    Text(dueDate.formatted(.dateTime.month(.abbreviated).day()))
                                        .font(.system(size: 11, weight: .medium))
                                }
                                .foregroundColor(isOverdue ? .red : Color(.systemGray2))
                                .padding(.horizontal, 9)
                                .padding(.vertical, 4)
                                .background(
                                    isOverdue
                                        ? Color.red.opacity(0.08)
                                        : Color(.systemGray6)
                                )
                                .clipShape(Capsule())
                            }

                            Spacer()
                        }

                        // Tags row
                        if let tags = task.tags, !tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 5) {
                                    ForEach(tags) { tag in
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(Color(hex: tag.colorHex))
                                                .frame(width: 6, height: 6)
                                            Text(tag.name)
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundColor(Color(hex: tag.colorHex))
                                        }
                                        .padding(.horizontal, 9)
                                        .padding(.vertical, 4)
                                        .background(Color(hex: tag.colorHex).opacity(0.08))
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(Color(hex: tag.colorHex).opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                    }

                    // MARK: - Subtask progress
                    if subtaskViewModel.totalCount > 0 {
                        VStack(alignment: .leading, spacing: 5) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color(.systemGray5))
                                        .frame(height: 5)
                                    Capsule()
                                        .fill(
                                            subtaskViewModel.allCompleted
                                                ? AnyShapeStyle(Color(hex: "10B981"))
                                                : AnyShapeStyle(LinearGradient(
                                                    colors: [purple, purple.opacity(0.6)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ))
                                        )
                                        .frame(
                                            width: geo.size.width * subtaskViewModel.progress,
                                            height: 5
                                        )
                                        .animation(.spring(response: 0.5), value: subtaskViewModel.progress)
                                }
                            }
                            .frame(height: 5)

                            HStack(spacing: 4) {
                                Image(systemName: subtaskViewModel.allCompleted
                                      ? "checkmark.circle.fill" : "circle.grid.2x1.left.filled")
                                    .font(.system(size: 10))
                                    .foregroundColor(
                                        subtaskViewModel.allCompleted
                                            ? Color(hex: "10B981") : .secondary
                                    )
                                Text("\(subtaskViewModel.progressText) subtasks")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.trailing, 16)
                .padding(.vertical, 16)
            }
        }
        // MARK: - Card styling
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    task.isCompleted
                        ? Color(.systemGray6).opacity(0.7)
                        : Color.white
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    task.isCompleted
                        ? Color(.systemGray5)
                        : priorityColor.opacity(0.12),
                    lineWidth: 1
                )
        )
        .shadow(
            color: task.isCompleted ? .clear : priorityColor.opacity(0.08),
            radius: 12, x: 0, y: 4
        )
        .animation(.easeInOut(duration: 0.25), value: task.isCompleted)
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

    // MARK: - Helpers
    private var priorityColor: Color {
        switch task.priority {
        case .urgent: return Color(hex: "EF4444")
        case .high:   return Color(hex: "F97316")
        case .medium: return Color(hex: "F59E0B")
        case .low:    return Color(hex: "10B981")
        }
    }

    private var categoryBgColor: Color {
        guard !task.isCompleted else { return Color(.systemGray5) }
        if let hex = task.category?.colorHex {
            return Color(hex: hex).opacity(0.12)
        }
        return purple.opacity(0.08)
    }
}
