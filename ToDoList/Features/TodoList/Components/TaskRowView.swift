//
//  TaskRowView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI

struct TaskRowView: View {
    let task: Task                              // ✅ unchanged
    @ObservedObject var viewModel: TaskListViewModel // ✅ unchanged

    var body: some View {
        HStack(spacing: 14) {
            // ✅ unchanged action
            Button(action: {
                _Concurrency.Task {
                    await viewModel.toggleTaskCompletion(task) // ✅ unchanged
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

            VStack(alignment: .leading, spacing: 5) {
                // ✅ unchanged properties
                Text(task.title)
                    .font(.system(size: 15, weight: .medium))
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)

                if !task.description.isEmpty {
                    Text(task.description) // ✅ unchanged
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 8) {
                    PriorityBadge(priority: task.priority) // ✅ unchanged

                    // ✅ unchanged dueDate logic
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
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(.systemGray4))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        // ✅ unchanged swipe action
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                _Concurrency.Task {
                    await viewModel.deleteTask(task) // ✅ unchanged
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
