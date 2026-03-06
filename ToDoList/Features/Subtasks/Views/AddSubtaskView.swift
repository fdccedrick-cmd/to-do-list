//
//  AddSubtaskView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//


import SwiftUI

struct AddSubtaskView: View {
    @ObservedObject var viewModel: SubtaskViewModel
    @State private var title = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Placeholder circle
            Circle()
                .stroke(Color(.systemGray4), lineWidth: 1.5)
                .frame(width: 20, height: 20)

            TextField("Add subtask...", text: $title)
                .font(.system(size: 14))
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit { submitSubtask() }

            if !title.isEmpty {
                Button { submitSubtask() } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.black)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .animation(.spring(response: 0.3), value: title.isEmpty)
    }

    private func submitSubtask() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let titleToAdd = title
        title = ""
        _Concurrency.Task {
            await viewModel.createSubtask(title: titleToAdd)
        }
    }
}
