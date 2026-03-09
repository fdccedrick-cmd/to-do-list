//
//  EditTaskView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI
import Auth

struct EditTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TaskListViewModel
    let task: Task

    @StateObject private var categoryViewModel = CategoryViewModel()
    @StateObject private var tagViewModel = TagViewModel()
    
    private let reminderService = ReminderService()
    private let notificationService = NotificationService.shared

    @State private var title = ""
    @State private var description = ""
    @State private var priority: TaskPriority = .medium
    @State private var dueDate: Date = Date()
    @State private var hasDueDate = false
    @State private var includeTime = false  
    @State private var selectedCategory: Category?
    @State private var selectedTags: Set<Tag> = []
    @State private var showCategoryPicker = false
    @State private var showTagPicker = false
    @State private var reminderDates: [Date] = [] 
    @State private var showReminderPicker = false 
    @State private var isLoadingData = true
    @FocusState private var focusedField: Field?

    enum Field { case title, description }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.96).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // MARK: - Task Details Card
                        formCard {
                            VStack(alignment: .leading, spacing: 16) {
                                cardLabel("TASK DETAILS")

                                // Title
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("TITLE")
                                        .font(.system(size: 10, weight: .semibold))
                                        .tracking(1.5)
                                        .foregroundColor(.secondary)

                                    TextField("What needs to be done?", text: $title)
                                        .font(.system(size: 16, weight: .medium))
                                        .focused($focusedField, equals: .title)
                                        .submitLabel(.next)
                                        .onSubmit { focusedField = .description }
                                        .padding(.bottom, 8)
                                        .overlay(alignment: .bottom) {
                                            Rectangle()
                                                .fill(focusedField == .title ? Color.black : Color(.systemGray5))
                                                .frame(height: focusedField == .title ? 1.5 : 1)
                                                .animation(.easeInOut(duration: 0.2), value: focusedField)
                                        }
                                }

                                // Description
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("DESCRIPTION")
                                        .font(.system(size: 10, weight: .semibold))
                                        .tracking(1.5)
                                        .foregroundColor(.secondary)

                                    TextField("Add details (optional)", text: $description, axis: .vertical)
                                        .font(.system(size: 15))
                                        .lineLimit(3...6)
                                        .focused($focusedField, equals: .description)
                                        .submitLabel(.done)
                                        .onSubmit { focusedField = nil }
                                        .padding(.bottom, 8)
                                        .overlay(alignment: .bottom) {
                                            Rectangle()
                                                .fill(focusedField == .description ? Color.black : Color(.systemGray5))
                                                .frame(height: focusedField == .description ? 1.5 : 1)
                                                .animation(.easeInOut(duration: 0.2), value: focusedField)
                                        }
                                }
                            }
                        }

                        // MARK: - Priority Card
                        formCard {
                            VStack(alignment: .leading, spacing: 12) {
                                cardLabel("PRIORITY")

                                HStack(spacing: 8) {
                                    ForEach(TaskPriority.allCases, id: \.self) { p in
                                        Button {
                                            withAnimation(.spring(response: 0.3)) {
                                                priority = p
                                            }
                                        } label: {
                                            Text(p.displayName)
                                                .font(.system(size: 13, weight: .semibold))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(
                                                    priority == p
                                                        ? Color.black
                                                        : Color(.systemGray6)
                                                )
                                                .foregroundColor(
                                                    priority == p ? .white : .primary
                                                )
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                    }
                                }
                            }
                        }

                        // MARK: - Category Card
                        formCard {
                            VStack(alignment: .leading, spacing: 12) {
                                cardLabel("CATEGORY")

                                Button { showCategoryPicker = true } label: {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(.systemGray6))
                                                .frame(width: 36, height: 36)

                                            if let category = selectedCategory {
                                                Text(category.icon)
                                                    .font(.system(size: 18))
                                            } else {
                                                Image(systemName: "folder")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.secondary)
                                            }
                                        }

                                        if let category = selectedCategory {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(category.name)
                                                    .font(.system(size: 15, weight: .medium))
                                                    .foregroundColor(.primary)
                                                Circle()
                                                    .fill(Color(hex: category.colorHex))
                                                    .frame(width: 8, height: 8)
                                            }
                                        } else {
                                            Text("Select Category")
                                                .font(.system(size: 15))
                                                .foregroundColor(.secondary)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }

                        // MARK: - Tags Card
                        formCard {
                            VStack(alignment: .leading, spacing: 12) {
                                cardLabel("TAGS")

                                Button { showTagPicker = true } label: {
                                    HStack {
                                        if selectedTags.isEmpty {
                                            HStack(spacing: 8) {
                                                Image(systemName: "tag")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.secondary)
                                                Text("Add Tags")
                                                    .font(.system(size: 15))
                                                    .foregroundColor(.secondary)
                                            }
                                        } else {
                                            FlowLayout(spacing: 6) {
                                                ForEach(Array(selectedTags), id: \.id) { tag in
                                                    HStack(spacing: 4) {
                                                        Circle()
                                                            .fill(Color(hex: tag.colorHex))
                                                            .frame(width: 8, height: 8)
                                                        Text(tag.name)
                                                            .font(.system(size: 12, weight: .medium))
                                                    }
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 5)
                                                    .background(Color(.systemGray6))
                                                    .clipShape(Capsule())
                                                }
                                            }
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }

                        // MARK: - Due Date Card
                        formCard {
                            VStack(alignment: .leading, spacing: 12) {
                                cardLabel("DUE DATE")

                                Toggle(isOn: $hasDueDate) {
                                    Text("Set due date")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                .tint(.black)

                                if hasDueDate {
                                    DatePicker(
                                        "Date",
                                        selection: $dueDate,
                                        displayedComponents: includeTime ? [.date, .hourAndMinute] : [.date]
                                    )
                                    .datePickerStyle(.graphical)
                                    .tint(.black)
                                    
                                    Toggle("Include Time", isOn: $includeTime)
                                        .tint(.black)
                                        .font(.system(size: 14))
                                }
                            }
                        }
                        
                        // MARK: - Reminders Card
                        if hasDueDate {
                            formCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    cardLabel("REMINDERS")
                                    
                                    Button {
                                        showReminderPicker = true
                                    } label: {
                                        HStack {
                                            Image(systemName: "bell")
                                                .font(.system(size: 14))
                                                .foregroundColor(.secondary)
                                            
                                            if reminderDates.isEmpty {
                                                Text("Add Reminders")
                                                    .font(.system(size: 15))
                                                    .foregroundColor(.secondary)
                                            } else {
                                                Text("\(reminderDates.count) reminder\(reminderDates.count == 1 ? "" : "s")")
                                                    .font(.system(size: 15))
                                                    .foregroundColor(.primary)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    if !reminderDates.isEmpty {
                                        VStack(spacing: 8) {
                                            ForEach(reminderDates.indices, id: \.self) { index in
                                                HStack {
                                                    Image(systemName: "bell.fill")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.orange)
                                                    Text(reminderDates[index].formatted(date: .abbreviated, time: .shortened))
                                                        .font(.system(size: 13))
                                                        .foregroundColor(.secondary)
                                                    Spacer()
                                                    Button {
                                                        reminderDates.remove(at: index)
                                                    } label: {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .font(.system(size: 16))
                                                            .foregroundColor(.secondary)
                                                    }
                                                }
                                                .padding(.vertical, 4)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        _Concurrency.Task {
                            await saveChanges()
                        }
                    }
                    .disabled(title.isEmpty)
                    .fontWeight(.semibold)
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
            .sheet(isPresented: $showReminderPicker) {
                ReminderPickerView(
                    reminderDates: $reminderDates,
                    dueDate: dueDate
                )
            }
            .task {
                await loadInitialData()
            }
        }
    }

    @MainActor
    private func loadInitialData() async {
        title = task.title
        description = task.description
        priority = task.priority
        selectedCategory = task.category
        selectedTags = Set(task.tags ?? [])
        
        if let dueDate = task.dueDate {
            self.dueDate = dueDate
            hasDueDate = true
            includeTime = task.dueTime != nil
        }
        if let userId = task.userId as UUID? {
            await categoryViewModel.fetchCategories(for: userId)
            await tagViewModel.fetchTags(for: userId)
            
            // Load existing reminders
            do {
                let reminders = try await reminderService.fetchReminders(for: task.id)
                reminderDates = reminders.map { $0.remindAt }
            } catch {
                print("Error loading reminders: \(error)")
            }
        }
    }

    @MainActor
    private func saveChanges() async {
        let timeString: String?
        if includeTime && hasDueDate {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            timeString = formatter.string(from: dueDate)
        } else {
            timeString = nil
        }
        
        let updatedTask = Task(
            id: task.id,
            userId: task.userId,
            categoryId: selectedCategory?.id,
            title: title,
            description: description,
            isCompleted: task.isCompleted,
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil,
            dueTime: timeString,
            completedAt: task.completedAt,
            sortOrder: task.sortOrder,
            createdAt: task.createdAt,
            updatedAt: Date(),
            category: selectedCategory,
            tags: Array(selectedTags),
            subtasks: task.subtasks
        )

        await viewModel.updateTask(updatedTask)
        
        // Handle reminders
        if !reminderDates.isEmpty {
            // Request notification permission
            let authorized = await notificationService.requestAuthorization()
            if authorized, let userId = task.userId as UUID? {
                do {
                    // Delete existing reminders
                    try await reminderService.deleteReminders(for: task.id)
                    
                    // Create new reminders
                    try await reminderService.createReminders(
                        taskId: task.id,
                        userId: userId,
                        reminderDates: reminderDates,
                        taskTitle: title
                    )
                } catch {
                    print("Error updating reminders: \(error)")
                }
            }
        } else {
            // Delete all reminders if none selected
            do {
                try await reminderService.deleteReminders(for: task.id)
            } catch {
                print("Error deleting reminders: \(error)")
            }
        }
        
        dismiss()
    }

    @ViewBuilder
    private func formCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    private func cardLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .tracking(2)
            .foregroundColor(.secondary)
    }
}
