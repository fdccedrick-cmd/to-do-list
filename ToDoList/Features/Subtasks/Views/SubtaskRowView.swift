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
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isAnimating = true
                }
                
                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                
                _Concurrency.Task {
                    await viewModel.toggleSubtask(subtask)
                    await MainActor.run {
                        withAnimation(.spring(response: 0.3)) {
                            isAnimating = false
                        }
                    }
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
                            .transition(.scale.combined(with: .opacity))
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .scaleEffect(isAnimating ? 1.3 : 1.0)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
            }
            .buttonStyle(.plain)

            Text(subtask.title)
                .font(.system(size: 14))
                .strikethrough(subtask.isCompleted, color: .secondary)
                .foregroundColor(subtask.isCompleted ? .secondary : .primary)
                .animation(.easeInOut(duration: 0.3), value: subtask.isCompleted)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            subtask.isCompleted ? Color.black.opacity(0.02) : Color.clear
        )
        .animation(.easeInOut(duration: 0.3), value: subtask.isCompleted)
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
