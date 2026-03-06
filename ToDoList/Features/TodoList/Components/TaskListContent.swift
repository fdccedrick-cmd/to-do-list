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
                
                QuickStatsRow(
                    upcomingCount: viewModel.upcomingTasks.count,
                    completedCount: viewModel.completedTasks.count,
                    overdueCount: viewModel.overdueTasks.count
                )
                
                // Celebration banner when no overdue tasks
                if viewModel.overdueTasks.isEmpty && !viewModel.incompleteTasks.isEmpty {
                    EmptyBanner(
                        icon: "checkmark.circle.fill",
                        title: "No overdue tasks 🎉",
                        message: "You're all caught up!",
                        iconColor: .green
                    )
                }
                
                // Celebration banner when all tasks completed
                if viewModel.incompleteTasks.isEmpty && !viewModel.tasks.isEmpty {
                    EmptyBanner(
                        icon: "star.fill",
                        title: "All tasks completed! ✨",
                        message: "Great work today!",
                        iconColor: .orange
                    )
                }

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
        let percentage = Int(progress * 100)

        return VStack(alignment: .leading, spacing: 16) {
            // Greeting Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greeting)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                    Text(viewModel.profile?.displayName ?? "there")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
                Text(greetingEmoji)
                    .font(.system(size: 36))
            }
            
            // Progress Info
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("You're \(percentage)% through today")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                    Text("\(completed) of \(total) tasks done")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Circular Progress
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 6)
                        .frame(width: 56, height: 56)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 56, height: 56)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6), value: progress)
                    Text("\(percentage)%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color.white.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 8)
                        .animation(.spring(response: 0.6), value: progress)
                }
            }
            .frame(height: 8)
            
            // Streak Badge
            HStack(spacing: 6) {
                Text("🔥")
                    .font(.system(size: 14))
                Text("1 day streak")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.15))
            .clipShape(Capsule())
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.1),
                    Color(red: 0.15, green: 0.15, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 4)
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }
    
    private var greetingEmoji: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "☀️"
        case 12..<17:
            return "🌤️"
        default:
            return "🌙"
        }
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
