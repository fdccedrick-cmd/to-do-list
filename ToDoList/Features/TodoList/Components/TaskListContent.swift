//
//  TaskListContent.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI

struct TaskListContent: View {
    @ObservedObject var viewModel: TaskListViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                progressCard

                if !viewModel.overdueTasks.isEmpty {
                    taskSection(title: "OVERDUE", icon: "exclamationmark.triangle.fill", iconColor: .red, tasks: viewModel.overdueTasks)
                }
                if !viewModel.todayTasks.isEmpty {
                    taskSection(title: "TODAY", icon: "calendar", iconColor: .black, tasks: viewModel.todayTasks)
                }
                if !viewModel.upcomingTasks.isEmpty {
                    taskSection(title: "UPCOMING", icon: "calendar.badge.clock", iconColor: Color(white: 0.4), tasks: viewModel.upcomingTasks)
                }

                let noDueDateTasks = viewModel.incompleteTasks.filter { $0.dueDate == nil }
                if !noDueDateTasks.isEmpty {
                    taskSection(title: "NO DUE DATE", icon: "tray", iconColor: Color(white: 0.5), tasks: noDueDateTasks)
                }
                if !viewModel.completedTasks.isEmpty {
                    taskSection(title: "COMPLETED", icon: "checkmark.circle.fill", iconColor: Color(white: 0.4), tasks: viewModel.completedTasks)
                }

                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .background(Color(white: 0.96))
    }

    private var progressCard: some View {
        let total = viewModel.tasks.count
        let completed = viewModel.completedTasks.count
        let progress = total > 0 ? Double(completed) / Double(total) : 0

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Progress")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text("\(completed) of \(total) tasks done")
                        .font(.system(size: 20, weight: .bold))
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 6)
                        .frame(width: 52, height: 52)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.black, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 52, height: 52)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6), value: progress)
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 11, weight: .bold))
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color(.systemGray5)).frame(height: 6)
                    RoundedRectangle(cornerRadius: 4).fill(Color.black)
                        .frame(width: geo.size.width * progress, height: 6)
                        .animation(.spring(response: 0.6), value: progress)
                }
            }
            .frame(height: 6)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private func taskSection(
        title: String,
        icon: String,
        iconColor: Color,
        tasks: [Task]
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(tasks.count)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(tasks) { task in
                    // ✅ NavigationLink wraps each row → goes to TaskDetailView
                    NavigationLink {
                        TaskDetailView(
                            task: task,
                            taskListViewModel: viewModel
                        )
                    } label: {
                        TaskRowView(task: task, viewModel: viewModel)
                    }
                    .buttonStyle(.plain)

                    if task.id != tasks.last?.id {
                        Divider().padding(.leading, 52)
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
    }
}
