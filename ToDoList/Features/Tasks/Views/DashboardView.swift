//
//  DashboardView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI
import Auth

enum TaskFilter: String, CaseIterable {
    case all = "All"
    case upcoming = "Upcoming"
    case completed = "Completed"
    case overdue = "Overdue"
}

struct DashboardView: View {
    @EnvironmentObject var authService: AuthService   
    @StateObject private var viewModel = TaskListViewModel()

    @State private var showAddTask = false
    @State private var showProfile = false
    @State private var showReminders = false
    @State private var selectedFilter: TaskFilter = .all

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.96).ignoresSafeArea()

                if viewModel.isLoading && viewModel.tasks.isEmpty {
                    loadingView
                } else if viewModel.tasks.isEmpty {
                    EmptyStateView(onAddTask: { showAddTask = true })
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Hero Banner
                            progressCard
                            
                            // Tab bar
                            tabBar
                            
                            // Filtered Tasks
                            filteredTasksContent
                            
                            Spacer().frame(height: 100)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }

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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showProfile = true } label: {
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 32, height: 32)

                                if let name = viewModel.profile?.displayName,
                                   let first = name.first {
                                    Text(String(first).uppercased())
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                }
                            }

                            VStack(alignment: .leading, spacing: 1) {
                                Text("Hello,")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Text(viewModel.profile?.displayName ?? "there")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("MY TASKS")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(3)
                        .foregroundColor(.primary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button { showReminders = true } label: {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                        }
                        
                        HStack(spacing: 4) {
                            Text("\(viewModel.incompleteTasks.count)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Color.black)
                                .clipShape(Circle())
                            Text("left")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(viewModel: viewModel, userId: authService.currentUser?.id ?? UUID())
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showReminders) {
                ReminderListView()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
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
            .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
        }
    }
    
    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TaskFilter.allCases, id: \.self) { filter in
                    TabButton(
                        title: filter.rawValue,
                        count: taskCount(for: filter),
                        isSelected: selectedFilter == filter,
                        filter: filter
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.leading, 0)
            .padding(.trailing, 8)
            .padding(.vertical, 2)
        }
        .padding(.horizontal, -16)
        .padding(.leading, 16)
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
                    
                    Text("\(percentage)%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.black, Color(white: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
    private var greetingEmoji: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "☀️"
        case 12..<17: return "🌤️"
        default: return "🌙"
        }
    }
    
    private var filteredTasksContent: some View {
        VStack(spacing: 8) {
            let tasks = filteredTasks

            if tasks.isEmpty {
                emptyFilterState
            } else {
                let incomplete = tasks.filter { !$0.isCompleted }
                let completed = tasks.filter { $0.isCompleted }

                if !incomplete.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(incomplete) { task in
                            NavigationLink(destination: TaskDetailView(
                                task: task,
                                taskListViewModel: viewModel
                            )) {
                                TaskRowView(task: task, viewModel: viewModel)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }

                if !completed.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color(.systemGray3))
                            Text("COMPLETED")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(Color(.systemGray3))
                            Text("\(completed.count)")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray3))
                                .clipShape(Capsule())
                        }
                        .padding(.top, 8)

                        ForEach(completed) { task in
                            NavigationLink(destination: TaskDetailView(
                                task: task,
                                taskListViewModel: viewModel
                            )) {
                                TaskRowView(task: task, viewModel: viewModel)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
    }
    
    private var emptyFilterState: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(emptyStateColor.opacity(0.1))
                    .frame(width: 64, height: 64)

                Image(systemName: emptyStateIcon)
                    .font(.system(size: 26))
                    .foregroundColor(emptyStateColor)
            }

            Text(emptyStateTitle)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.primary)

            Text(emptyStateMessage)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // Add this alongside existing emptyState vars
    private var emptyStateColor: Color {
        switch selectedFilter {
        case .all:       return .secondary
        case .upcoming:  return Color(hex: "3B82F6")
        case .completed: return Color(hex: "10B981")
        case .overdue:   return Color(hex: "EF4444")
        }
    }
    
    private var emptyStateIcon: String {
        switch selectedFilter {
        case .all: return "tray"
        case .upcoming: return "calendar.badge.clock"
        case .completed: return "checkmark.circle"
        case .overdue: return "exclamationmark.triangle"
        }
    }
    
    private var emptyStateTitle: String {
        switch selectedFilter {
        case .all: return "No Tasks"
        case .upcoming: return "No Upcoming Tasks"
        case .completed: return "No Completed Tasks"
        case .overdue: return "No Overdue Tasks"
        }
    }
    
    private var emptyStateMessage: String {
        switch selectedFilter {
        case .all: return "Tap the + button to create your first task"
        case .upcoming: return "All caught up! No tasks scheduled for later"
        case .completed: return "Complete some tasks to see them here"
        case .overdue: return "Great! You're all caught up"
        }
    }
    
    private var filteredTasks: [Task] {
        switch selectedFilter {
        case .all:
            return viewModel.tasks
        case .upcoming:
            return viewModel.upcomingTasks
        case .completed:
            return viewModel.completedTasks
        case .overdue:
            return viewModel.overdueTasks
        }
    }
    
    private func taskCount(for filter: TaskFilter) -> Int {
        switch filter {
        case .all:
            return viewModel.tasks.count
        case .upcoming:
            return viewModel.upcomingTasks.count
        case .completed:
            return viewModel.completedTasks.count
        case .overdue:
            return viewModel.overdueTasks.count
        }
    }
}

// MARK: - Tab Button

struct TabButton: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let filter: TaskFilter
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {

                // Filter icon
                Image(systemName: filterIcon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(isSelected ? .white : filterIconColor)

                // Label
                Text(title)
                    .font(.system(size: 12, weight: isSelected ? .bold : .semibold))
                    .foregroundColor(isSelected ? .white : .secondary)

                // Count badge — only show if > 0
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isSelected ? filterAccentColor : .white)
                        .frame(minWidth: 18, minHeight: 18)
                        .background(
                            isSelected
                                ? Color.white
                                : Color(.systemGray4)
                        )
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Group {
                    if isSelected {
                        // Selected: solid colored pill
                        Capsule()
                            .fill(filterFillColor)
                    } else {
                        // Unselected: subtle outlined pill
                        Capsule()
                            .fill(Color(.systemGray6))
                    }
                }
            )
            .overlay(
                Capsule()
                    .stroke(
                        isSelected
                            ? Color.clear
                            : Color(.systemGray5),
                        lineWidth: 1
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Per-filter styling

    private var filterIcon: String {
        switch filter {
        case .all:       return "square.grid.2x2"
        case .upcoming:  return "calendar.badge.clock"
        case .completed: return "checkmark.circle.fill"
        case .overdue:   return "exclamationmark.triangle.fill"
        }
    }

    private var filterIconColor: Color {
        switch filter {
        case .all:       return .secondary
        case .upcoming:  return Color(hex: "3B82F6")   // blue
        case .completed: return Color(hex: "10B981")   // green
        case .overdue:   return Color(hex: "EF4444")   // red
        }
    }

    private var filterAccentColor: Color {
        switch filter {
        case .all:       return .black
        case .upcoming:  return Color(hex: "3B82F6")
        case .completed: return Color(hex: "10B981")
        case .overdue:   return Color(hex: "EF4444")
        }
    }

    private var filterFillColor: Color {
        switch filter {
        case .all:
            return .black
        case .upcoming:
            return Color(hex: "3B82F6")   // blue
        case .completed:
            return Color(hex: "10B981")   // green
        case .overdue:
            return Color(hex: "EF4444")   // red
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthService())
}
