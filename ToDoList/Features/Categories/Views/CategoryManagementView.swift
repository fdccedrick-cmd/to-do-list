//
//  CategoryManagementView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI
import Auth

struct CategoryManagementView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = CategoryViewModel()
    
    @State private var showAddCategory = false
    var showDismissButton: Bool = false // Add flag for sheet presentation
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.categories) { category in
                    CategoryRow(category: category, viewModel: viewModel)
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if showDismissButton {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddCategory) {
                AddCategoryView(viewModel: viewModel, userId: authService.currentUser?.id ?? UUID())
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
                    await viewModel.fetchCategories(for: userId)
                }
            }
        }
    }
}

// MARK: - Category Row

struct CategoryRow: View {
    let category: Category
    @ObservedObject var viewModel: CategoryViewModel
    @State private var showEdit = false
    
    var body: some View {
        HStack(spacing: 12) {
            Text(category.icon)
                .font(.title2)
            
            Text(category.name)
                .font(.body)
            
            Spacer()
            
            Circle()
                .fill(Color(hex: category.colorHex))
                .frame(width: 20, height: 20)
            
            if category.isDefault {
                Text("Default")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            if !category.isDefault {
                showEdit = true
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if !category.isDefault {
                Button(role: .destructive) {
                    _Concurrency.Task {
                        await viewModel.deleteCategory(category)
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            EditCategoryView(category: category, viewModel: viewModel)
        }
    }
}

// MARK: - Add Category View

struct AddCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CategoryViewModel
    let userId: UUID
    
    @State private var name = ""
    @State private var selectedIcon = "📁"
    @State private var selectedColor = "#3B82F6"
    
    let availableIcons = ["📁", "💼", "🏠", "💪", "📚", "🎯", "💰", "🏥", "🛒", "✈️", "🎵", "🎨"]
    let availableColors = ["#3B82F6", "#EF4444", "#10B981", "#F59E0B", "#8B5CF6", "#EC4899", "#14B8A6", "#F97316"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category Name") {
                    TextField("Enter name", text: $name)
                }
                
                Section("Icon") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 16) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Text(icon)
                                .font(.largeTitle)
                                .frame(width: 50, height: 50)
                                .background(selectedIcon == icon ? Color.gray.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                }
                
                Section("Color") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 16) {
                        ForEach(availableColors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                }
            }
            .navigationTitle("New Category")
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
                            await viewModel.createCategory(
                                userId: userId,
                                name: name,
                                icon: selectedIcon,
                                colorHex: selectedColor
                            )
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Edit Category View

struct EditCategoryView: View {
    @Environment(\.dismiss) var dismiss
    let category: Category
    @ObservedObject var viewModel: CategoryViewModel
    
    @State private var name = ""
    @State private var selectedIcon = ""
    @State private var selectedColor = ""
    
    let availableIcons = ["📁", "💼", "🏠", "💪", "📚", "🎯", "💰", "🏥", "🛒", "✈️", "🎵", "🎨"]
    let availableColors = ["#3B82F6", "#EF4444", "#10B981", "#F59E0B", "#8B5CF6", "#EC4899", "#14B8A6", "#F97316"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category Name") {
                    TextField("Enter name", text: $name)
                }
                
                Section("Icon") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 16) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Text(icon)
                                .font(.largeTitle)
                                .frame(width: 50, height: 50)
                                .background(selectedIcon == icon ? Color.gray.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                }
                
                Section("Color") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 16) {
                        ForEach(availableColors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                }
            }
            .navigationTitle("Edit Category")
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
                            var updated = category
                            updated.name = name
                            updated.icon = selectedIcon
                            updated.colorHex = selectedColor
                            await viewModel.updateCategory(updated)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                name = category.name
                selectedIcon = category.icon
                selectedColor = category.colorHex
            }
        }
    }
}

#Preview {
    CategoryManagementView()
        .environmentObject(AuthService())
}
