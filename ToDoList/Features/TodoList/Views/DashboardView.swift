//
//  DashboardView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI
import Auth

struct DashboardView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = TaskListViewModel()
    
    @State private var showAddTask = false
    @State private var showProfile = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.tasks.isEmpty {
                    // Loading state
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading your tasks...")
                            .foregroundStyle(.secondary)
                    }
                } else if viewModel.tasks.isEmpty {
                    // Empty state
                    EmptyStateView(onAddTask: { showAddTask = true })
                } else {
                    // Task list
                    TaskListContent(viewModel: viewModel)
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(viewModel: viewModel, userId: authService.currentUser?.id ?? UUID())
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .task {
                if let userId = authService.currentUser?.id {
                    await viewModel.fetchTasks(for: userId)
                }
            }
            .refreshable {
                if let userId = authService.currentUser?.id {
                    await viewModel.refreshTasks(for: userId)
                }
            }
        }
    }
}

// MARK: - Task List Content

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

// MARK: - Task Row View

struct TaskRowView: View {
    let task: Task
    @ObservedObject var viewModel: TaskListViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion checkbox
            Button(action: {
                _Concurrency.Task {
                    await viewModel.toggleTaskCompletion(task)
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    // Priority badge
                    PriorityBadge(priority: task.priority)
                    
                    // Due date
                    if let dueDate = task.dueDate {
                        Label(dueDate.formatted(.dateTime.month().day()), systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                _Concurrency.Task {
                    await viewModel.deleteTask(task)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Priority Badge

struct PriorityBadge: View {
    let priority: TaskPriority
    
    var body: some View {
        Text(priority.displayName)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(priorityColor.opacity(0.2))
            .foregroundStyle(priorityColor)
            .clipShape(Capsule())
    }
    
    private var priorityColor: Color {
        switch priority {
        case .low:
            return .blue
        case .medium:
            return .orange
        case .high:
            return .red
        case .urgent:
            return .purple
        }
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let onAddTask: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checklist")
                .font(.system(size: 70))
                .foregroundStyle(.blue.gradient)
            
            Text("No Tasks Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Get started by adding your first task")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button {
                onAddTask()
            } label: {
                Label("Add Task", systemImage: "plus")
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

// MARK: - Add Task View

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthService
    @ObservedObject var viewModel: TaskListViewModel
    let userId: UUID
    
    @StateObject private var categoryViewModel = CategoryViewModel()
    @StateObject private var tagViewModel = TagViewModel()
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: TaskPriority = .medium
    @State private var dueDate: Date = Date()
    @State private var hasDueDate = false
    @State private var selectedCategory: Category?
    @State private var selectedTags: Set<Tag> = []
    
    @State private var showCategoryPicker = false
    @State private var showTagPicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Title", text: $title)
                    
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Category") {
                    Button(action: { showCategoryPicker = true }) {
                        HStack {
                            if let category = selectedCategory {
                                Text(category.icon)
                                Text(category.name)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Circle()
                                    .fill(Color(hex: category.colorHex))
                                    .frame(width: 20, height: 20)
                            } else {
                                Text("Select Category")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                Section("Tags") {
                    Button(action: { showTagPicker = true }) {
                        HStack {
                            if selectedTags.isEmpty {
                                Text("Add Tags")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            } else {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(Array(selectedTags), id: \.id) { tag in
                                        HStack(spacing: 6) {
                                            Circle()
                                                .fill(Color(hex: tag.colorHex))
                                                .frame(width: 12, height: 12)
                                            Text(tag.name)
                                                .foregroundStyle(.primary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Toggle("Set Due Date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date])
                    }
                }
            }
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        _Concurrency.Task {
                            await viewModel.createTask(
                                userId: userId,
                                title: title,
                                description: description,
                                priority: priority,
                                categoryId: selectedCategory?.id,
                                dueDate: hasDueDate ? dueDate : nil
                            )
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerView(
                    categories: categoryViewModel.categories,
                    selectedCategory: $selectedCategory
                )
            }
            .sheet(isPresented: $showTagPicker) {
                TagPickerView(
                    tags: tagViewModel.tags,
                    selectedTags: $selectedTags
                )
            }
            .task {
                if let userId = authService.currentUser?.id {
                    await categoryViewModel.fetchCategories(for: userId)
                    await tagViewModel.fetchTags(for: userId)
                }
            }
        }
    }
}

// MARK: - Category Picker

struct CategoryPickerView: View {
    @Environment(\.dismiss) var dismiss
    let categories: [Category]
    @Binding var selectedCategory: Category?
    
    var body: some View {
        NavigationStack {
            List {
                Button(action: {
                    selectedCategory = nil
                    dismiss()
                }) {
                    HStack {
                        Text("None")
                        Spacer()
                        if selectedCategory == nil {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                
                ForEach(categories) { category in
                    Button(action: {
                        selectedCategory = category
                        dismiss()
                    }) {
                        HStack {
                            Text(category.icon)
                            Text(category.name)
                                .foregroundStyle(.primary)
                            Spacer()
                            Circle()
                                .fill(Color(hex: category.colorHex))
                                .frame(width: 20, height: 20)
                            if selectedCategory?.id == category.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Tag Picker

struct TagPickerView: View {
    @Environment(\.dismiss) var dismiss
    let tags: [Tag]
    @Binding var selectedTags: Set<Tag>
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(tags) { tag in
                    Button(action: {
                        if selectedTags.contains(tag) {
                            selectedTags.remove(tag)
                        } else {
                            selectedTags.insert(tag)
                        }
                    }) {
                        HStack {
                            Circle()
                                .fill(Color(hex: tag.colorHex))
                                .frame(width: 12, height: 12)
                            Text(tag.name)
                                .foregroundStyle(.primary)
                            Spacer()
                            if selectedTags.contains(tag) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Profile View

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthService
    
    @State private var showCategoryManagement = false
    @State private var showTagManagement = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authService.currentUser?.email ?? "User")
                                .font(.headline)
                            
                            Text("Member since \(Date().formatted(.dateTime.year()))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Organization") {
                    Button(action: { showCategoryManagement = true }) {
                        Label("Categories", systemImage: "folder.fill")
                            .foregroundStyle(.primary)
                    }
                    
                    Button(action: { showTagManagement = true }) {
                        Label("Tags", systemImage: "tag.fill")
                            .foregroundStyle(.primary)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        _Concurrency.Task {
                            try? await authService.signOut()
                            dismiss()
                        }
                    } label: {
                        Label("Sign Out", systemImage: "arrow.right.square")
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showCategoryManagement) {
                CategoryManagementView()
            }
            .sheet(isPresented: $showTagManagement) {
                TagManagementView()
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthService())
}
