//
//  AddTaskView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI
import Auth

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
