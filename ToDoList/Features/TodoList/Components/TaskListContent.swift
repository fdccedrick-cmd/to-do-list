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
        List {
            // Overdue tasks
            if !viewModel.overdueTasks.isEmpty {
                Section {
                    ForEach(viewModel.overdueTasks) { task in
                        TaskRowView(task: task, viewModel: viewModel)
                    }
                } header: {
                    Label("Overdue", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                }
            }
            
            // Today's tasks
            if !viewModel.todayTasks.isEmpty {
                Section {
                    ForEach(viewModel.todayTasks) { task in
                        TaskRowView(task: task, viewModel: viewModel)
                    }
                } header: {
                    Label("Today", systemImage: "calendar")
                        .foregroundStyle(.blue)
                }
            }
            
            // Upcoming tasks
            if !viewModel.upcomingTasks.isEmpty {
                Section {
                    ForEach(viewModel.upcomingTasks) { task in
                        TaskRowView(task: task, viewModel: viewModel)
                    }
                } header: {
                    Label("Upcoming", systemImage: "calendar.badge.clock")
                        .foregroundStyle(.orange)
                }
            }
            
            // Tasks without due date
            let noDueDateTasks = viewModel.incompleteTasks.filter { $0.dueDate == nil }
            if !noDueDateTasks.isEmpty {
                Section("No Due Date") {
                    ForEach(noDueDateTasks) { task in
                        TaskRowView(task: task, viewModel: viewModel)
                    }
                }
            }
            
            // Completed tasks
            if !viewModel.completedTasks.isEmpty {
                Section {
                    ForEach(viewModel.completedTasks) { task in
                        TaskRowView(task: task, viewModel: viewModel)
                    }
                } header: {
                    Label("Completed", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
