//
//  EditSubtaskView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI

struct EditSubtaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SubtaskViewModel
    let subtask: Subtask
    
    @State private var title = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.96).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SUBTASK TITLE")
                            .font(.system(size: 10, weight: .semibold))
                            .tracking(1.5)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter subtask title", text: $title)
                            .font(.system(size: 16, weight: .medium))
                            .focused($isFocused)
                            .submitLabel(.done)
                            .onSubmit { saveChanges() }
                            .padding(.bottom, 8)
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(isFocused ? Color.black : Color(.systemGray5))
                                    .frame(height: isFocused ? 1.5 : 1)
                                    .animation(.easeInOut(duration: 0.2), value: isFocused)
                            }
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .navigationTitle("Edit Subtask")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                title = subtask.title
                isFocused = true
            }
        }
    }
    
    private func saveChanges() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        _Concurrency.Task {
            let updatedSubtask = Subtask(
                id: subtask.id,
                taskId: subtask.taskId,
                title: title,
                isCompleted: subtask.isCompleted,
                sortOrder: subtask.sortOrder,
                createdAt: subtask.createdAt,
                updatedAt: Date()
            )
            await viewModel.updateSubtask(updatedSubtask)
            dismiss()
        }
    }
}
