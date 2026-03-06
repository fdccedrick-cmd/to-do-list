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

    init(task: Task, viewModel: TaskListViewModel) {
        self.task = task
        self.viewModel = viewModel
        _subtaskViewModel = StateObject(
            wrappedValue: SubtaskViewModel(taskId: task.id)
        )
    }

    var body: some View {
        HStack(spacing: 14) {
            // ✅ unchanged toggle
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
                        .frame(width: 24, height: 24)

                    if task.isCompleted {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                // ✅ unchanged title
                Text(task.title)
                    .font(.system(size: 15, weight: .medium))
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)

                // ✅ unchanged description
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                // MARK: - Category badge
                if let category = task.category {
                    HStack(spacing: 4) {
                        Text(category.icon)
                            .font(.system(size: 10))
                        Text(category.name)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Color(hex: category.colorHex).opacity(0.12)
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color(hex: category.colorHex).opacity(0.3), lineWidth: 1)
                    )
                    .clipShape(Capsule())
                }

                // MARK: - Tags row
                if let tags = task.tags, !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(tags) { tag in
                                HStack(spacing: 3) {
                                    Circle()
                                        .fill(Color(hex: tag.colorHex))
                                        .frame(width: 6, height: 6)
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

                // MARK: - Bottom meta row (priority + duedate + subtasks)
                HStack(spacing: 8) {
                    // ✅ unchanged priority badge
                    PriorityBadge(priority: task.priority)

                    // ✅ unchanged due date
                    if let dueDate = task.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                            Text(dueDate.formatted(.dateTime.month().day()))
                                .font(.system(size: 11))
                        }
                        .foregroundColor(
                            dueDate < Date() && !task.isCompleted ? .red : .secondary
                        )
                    }

                    // ✅ unchanged subtask progress badge
                    if subtaskViewModel.totalCount > 0 {
                        HStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .stroke(Color(.systemGray5), lineWidth: 2)
                                    .frame(width: 14, height: 14)
                                Circle()
                                    .trim(from: 0, to: subtaskViewModel.progress)
                                    .stroke(
                                        Color.black,
                                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                                    )
                                    .frame(width: 14, height: 14)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.spring(response: 0.4), value: subtaskViewModel.progress)
                            }
                            Text(subtaskViewModel.progressText)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(.systemGray4))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        // ✅ unchanged swipe
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                _Concurrency.Task {
                    await viewModel.deleteTask(task)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .task {
            await subtaskViewModel.fetchSubtasks()
        }
    }
}
