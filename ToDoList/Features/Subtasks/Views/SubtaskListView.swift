//
//  SubtaskListView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//
import SwiftUI

struct SubtaskListView: View {
    @StateObject var viewModel: SubtaskViewModel
    @State private var showAllCompletedCelebration = false
    @State private var previousProgress: Double = 0

    init(taskId: UUID) {
        _viewModel = StateObject(wrappedValue: SubtaskViewModel(taskId: taskId))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: - Header with progress
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SUBTASKS")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(2)
                        .foregroundColor(.secondary)

                    if viewModel.totalCount > 0 {
                        Text(viewModel.progressText)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }

                Spacer()

                // Progress ring
                if viewModel.totalCount > 0 {
                    ZStack {
                        Circle()
                            .stroke(Color(.systemGray5), lineWidth: 3)
                            .frame(width: 28, height: 28)

                        Circle()
                            .trim(from: 0, to: viewModel.progress)
                            .stroke(
                                viewModel.allCompleted ? Color.green : Color.black,
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                            .frame(width: 28, height: 28)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 0.5), value: viewModel.progress)

                        if viewModel.allCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.green)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .onChange(of: viewModel.progress) { oldValue, newValue in
                        // Show celebration when all subtasks completed
                        if newValue == 1.0 && oldValue < 1.0 && viewModel.totalCount > 0 {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                showAllCompletedCelebration = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showAllCompletedCelebration = false
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 10)

            // MARK: - Progress bar
            if viewModel.totalCount > 0 {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(.systemGray5))
                            .frame(height: 3)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.black)
                            .frame(width: geo.size.width * viewModel.progress, height: 3)
                            .animation(.spring(response: 0.5), value: viewModel.progress)
                    }
                }
                .frame(height: 3)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }

            Divider()

            // MARK: - Subtask rows
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView().tint(.black)
                    Spacer()
                }
                .padding(.vertical, 16)
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.subtasks) { subtask in
                        SubtaskRowView(subtask: subtask, viewModel: viewModel)
                        if subtask.id != viewModel.subtasks.last?.id {
                            Divider().padding(.leading, 48)
                        }
                    }
                }

                Divider().padding(.leading, 48)

                // MARK: - Add subtask inline
                AddSubtaskView(viewModel: viewModel)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .overlay(alignment: .top) {
            if showAllCompletedCelebration {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.yellow)
                    Text("All subtasks completed!")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.green.opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(100)
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            if let msg = viewModel.errorMessage { Text(msg) }
        }
        .task {
            await viewModel.fetchSubtasks()
        }
    }
}
