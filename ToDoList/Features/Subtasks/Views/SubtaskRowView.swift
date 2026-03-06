//
//  SubtaskRowView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//


import SwiftUI

struct SubtaskRowView: View {
    let subtask: Subtask
    @ObservedObject var viewModel: SubtaskViewModel
    
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button {
                _Concurrency.Task {
                    await viewModel.toggleSubtask(subtask)
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(
                            subtask.isCompleted ? Color.black : Color(.systemGray4),
                            lineWidth: 1.5
                        )
                        .frame(width: 20, height: 20)

                    if subtask.isCompleted {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 20, height: 20)
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            Text(subtask.title)
                .font(.system(size: 14))
                .strikethrough(subtask.isCompleted, color: .secondary)
                .foregroundColor(subtask.isCompleted ? .secondary : .primary)
                .animation(.easeInOut(duration: 0.2), value: subtask.isCompleted)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                showEditSheet = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
        .sheet(isPresented: $showEditSheet) {
            EditSubtaskView(viewModel: viewModel, subtask: subtask)
        }
        .alert("Delete Subtask", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                _Concurrency.Task {
                    await viewModel.deleteSubtask(subtask)
                }
            }
        } message: {
            Text("Are you sure you want to delete '\(subtask.title)'?")
        }
    }
}
