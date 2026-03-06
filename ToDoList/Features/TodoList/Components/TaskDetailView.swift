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
                                _Concurrency.Task {
                                    await taskListViewModel.toggleTaskCompletion(task)
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
                                    }
                                }
                            }
                            .buttonStyle(.plain)

                            Text(task.title)
                                .font(.system(size: 20, weight: .bold))
                                .strikethrough(task.isCompleted, color: .secondary)
                                .foregroundColor(task.isCompleted ? .secondary : .primary)
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

                            // ✅ Category row
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

                            // ✅ Tags row
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
                        }
                    }
                    .padding(18)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)

                    // MARK: - Subtasks ✅ integrated here
                    SubtaskListView(taskId: task.id)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("TASK DETAIL")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(3)
            }
        }
    }
}
