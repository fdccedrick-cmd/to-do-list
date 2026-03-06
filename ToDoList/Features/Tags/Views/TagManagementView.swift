//
//  TagManagementView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI
import Auth

struct TagManagementView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = TagViewModel()
    
    @State private var showAddTag = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.tags) { tag in
                    TagRow(tag: tag, viewModel: viewModel)
                }
            }
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddTag = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddTag) {
                AddTagView(viewModel: viewModel, userId: authService.currentUser?.id ?? UUID())
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
                    await viewModel.fetchTags(for: userId)
                }
            }
        }
    }
}

// MARK: - Tag Row

struct TagRow: View {
    let tag: Tag
    @ObservedObject var viewModel: TagViewModel
    @State private var showEdit = false
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: tag.colorHex))
                .frame(width: 12, height: 12)
            
            Text(tag.name)
                .font(.body)
            
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            showEdit = true
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                _Concurrency.Task {
                    await viewModel.deleteTag(tag)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showEdit) {
            EditTagView(tag: tag, viewModel: viewModel)
        }
    }
}

// MARK: - Add Tag View

struct AddTagView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TagViewModel
    let userId: UUID
    
    @State private var name = ""
    @State private var selectedColor = "#3B82F6"
    
    let availableColors = [
        "#3B82F6", "#EF4444", "#10B981", "#F59E0B", 
        "#8B5CF6", "#EC4899", "#14B8A6", "#F97316",
        "#6366F1", "#84CC16", "#06B6D4", "#F43F5E"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Tag Name") {
                    TextField("Enter name", text: $name)
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
            .navigationTitle("New Tag")
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
                            await viewModel.createTag(
                                userId: userId,
                                name: name,
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

// MARK: - Edit Tag View

struct EditTagView: View {
    @Environment(\.dismiss) var dismiss
    let tag: Tag
    @ObservedObject var viewModel: TagViewModel
    
    @State private var name = ""
    @State private var selectedColor = ""
    
    let availableColors = [
        "#3B82F6", "#EF4444", "#10B981", "#F59E0B", 
        "#8B5CF6", "#EC4899", "#14B8A6", "#F97316",
        "#6366F1", "#84CC16", "#06B6D4", "#F43F5E"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Tag Name") {
                    TextField("Enter name", text: $name)
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
            .navigationTitle("Edit Tag")
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
                            var updated = tag
                            updated.name = name
                            updated.colorHex = selectedColor
                            await viewModel.updateTag(updated)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                name = tag.name
                selectedColor = tag.colorHex
            }
        }
    }
}

#Preview {
    TagManagementView()
        .environmentObject(AuthService())
}
