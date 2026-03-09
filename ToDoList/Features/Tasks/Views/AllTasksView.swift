//
//  AllTasksView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI
import Auth

struct AllTasksView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = TaskListViewModel()
    @State private var showAddTask = false
    @State private var searchText = ""
    @State private var selectedFilter: TaskFilter = .all
    @State private var selectedSort: TaskSort = .dueDate
    
    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case upcoming = "Upcoming"
        case overdue = "Overdue"
        case completed = "Completed"
    }
    
    enum TaskSort: String, CaseIterable {
        case dueDate = "Due Date"
        case priority = "Priority"
        case title = "Title"
    }
    
    var filteredTasks: [Task] {
        var tasks: [Task]
        
        switch selectedFilter {
        case .all:
            tasks = viewModel.tasks
        case .today:
            tasks = viewModel.todayTasks
        case .upcoming:
            tasks = viewModel.upcomingTasks
        case .overdue:
            tasks = viewModel.overdueTasks
        case .completed:
            tasks = viewModel.completedTasks
        }
        
        if !searchText.isEmpty {
            tasks = tasks.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return sortTasks(tasks)
    }
    
    func sortTasks(_ tasks: [Task]) -> [Task] {
        switch selectedSort {
        case .dueDate:
            return tasks.sorted { task1, task2 in
                guard let date1 = task1.dueDate else { return false }
                guard let date2 = task2.dueDate else { return true }
                return date1 < date2
            }
        case .priority:
            return tasks.sorted { priorityValue($0.priority) > priorityValue($1.priority) }
        case .title:
            return tasks.sorted { $0.title < $1.title }
        }
    }
    
    func priorityValue(_ priority: TaskPriority) -> Int {
        switch priority {
        case .urgent: return 4
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.96).ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.tasks.isEmpty {
                    loadingView
                } else if filteredTasks.isEmpty {
                    emptyStateView
                } else {
                    taskListView
                }
                
                // FAB
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        addButton
                            .padding(.trailing, 24)
                            .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("All Tasks")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search tasks...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Filter", selection: $selectedFilter) {
                            ForEach(TaskFilter.allCases, id: \.self) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                        
                        Picker("Sort", selection: $selectedSort) {
                            ForEach(TaskSort.allCases, id: \.self) { sort in
                                Text(sort.rawValue).tag(sort)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 18))
                    }
                }
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(viewModel: viewModel, userId: authService.currentUser?.id ?? UUID())
            }
            .task {
                guard let userId = authService.currentUser?.id else { return }
                await viewModel.loadDashboard(for: userId)
            }
            .refreshable {
                guard let userId = authService.currentUser?.id else { return }
                await viewModel.refreshTasks(for: userId)
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 72, height: 72)
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.black)
            }
            Text("Loading your tasks...")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: searchText.isEmpty ? "checkmark.circle" : "magnifyingglass")
                .font(.system(size: 56))
                .foregroundColor(.secondary)
            Text(searchText.isEmpty ? "No tasks here" : "No results found")
                .font(.system(size: 18, weight: .semibold))
            Text(searchText.isEmpty ? "Start by creating a new task" : "Try a different search term")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }
    
    private var taskListView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(filteredTasks) { task in
                    NavigationLink {
                        TaskDetailView(task: task, taskListViewModel: viewModel)
                    } label: {
                        TaskRowView(task: task, viewModel: viewModel)
                    }
                    .buttonStyle(.plain)
                    
                    if task.id != filteredTasks.last?.id {
                        Divider().padding(.leading, 52)
                    }
                }
            }
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            Spacer().frame(height: 100)
        }
    }
    
    private var addButton: some View {
        Button { showAddTask = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                Text("New Task")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.black)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    AllTasksView()
        .environmentObject(AuthService())
}
