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

    @State private var subtaskTitles: [String] = []   // ✅
    @State private var newSubtaskTitle: String = ""
    @State private var title = ""                        // ✅ unchanged
    @State private var description = ""                  // ✅ unchanged
    @State private var priority: TaskPriority = .medium  // ✅ unchanged
    @State private var dueDate: Date = Date()            // ✅ unchanged
    @State private var hasDueDate = false                // ✅ unchanged
    @State private var selectedCategory: Category?       // ✅ unchanged
    @State private var selectedTags: Set<Tag> = []       // ✅ unchanged
    @State private var showCategoryPicker = false        // ✅ unchanged
    @State private var showTagPicker = false             // ✅ unchanged
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

                                    // ✅ unchanged binding + axis
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

                                // ✅ unchanged ForEach + binding
                                HStack(spacing: 8) {
                                    ForEach(TaskPriority.allCases, id: \.self) { p in
                                        Button {
                                            withAnimation(.spring(response: 0.3)) {
                                                priority = p  // ✅ unchanged
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

                                // ✅ unchanged action
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

                                // ✅ unchanged action
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
                                            // ✅ unchanged tags display
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
                        // MARK: - Subtasks Card
                        formCard {
                            VStack(alignment: .leading, spacing: 12) {
                                cardLabel("SUBTASKS")

                                // Existing subtask titles preview
                                if !subtaskTitles.isEmpty {
                                    VStack(spacing: 0) {
                                        ForEach(subtaskTitles.indices, id: \.self) { index in
                                            HStack(spacing: 10) {
                                                Circle()
                                                    .stroke(Color(.systemGray4), lineWidth: 1.5)
                                                    .frame(width: 16, height: 16)

                                                Text(subtaskTitles[index])
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.primary)

                                                Spacer()

                                                // Remove
                                                Button {
                                                    subtaskTitles.remove(at: index)
                                                } label: {
                                                    Image(systemName: "xmark")
                                                        .font(.system(size: 11, weight: .medium))
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            .padding(.vertical, 8)

                                            if index < subtaskTitles.count - 1 {
                                                Divider().padding(.leading, 26)
                                            }
                                        }
                                    }

                                    Divider()
                                }

                                // ✅ Inline add subtask
                                HStack(spacing: 10) {
                                    Circle()
                                        .stroke(Color(.systemGray4), lineWidth: 1.5)
                                        .frame(width: 16, height: 16)

                                    TextField("Add a subtask...", text: $newSubtaskTitle)
                                        .font(.system(size: 14))
                                        .submitLabel(.done)
                                        .onSubmit { addSubtaskTitle() }

                                    if !newSubtaskTitle.isEmpty {
                                        Button { addSubtaskTitle() } label: {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(.black)
                                        }
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .animation(.spring(response: 0.3), value: newSubtaskTitle.isEmpty)
                            }
                        }

                        // MARK: - Due Date Card
                        formCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    cardLabel("DUE DATE")
                                    Spacer()
                                    // ✅ unchanged Toggle binding
                                    Toggle("", isOn: $hasDueDate)
                                        .tint(.black)
                                        .labelsHidden()
                                }

                                if hasDueDate {
                                    // ✅ unchanged DatePicker binding
                                    DatePicker(
                                        "Due Date",
                                        selection: $dueDate,
                                        displayedComponents: [.date]
                                    )
                                    .datePickerStyle(.graphical)
                                    .tint(.black)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                }
                            }
                            .animation(.spring(response: 0.4), value: hasDueDate)
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("NEW TASK")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(3)
                }

                // ✅ unchanged action
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }

                // ✅ unchanged action + disabled logic
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        _Concurrency.Task {
                            // ✅ Step 1: create task (unchanged)
                            await viewModel.createTask(
                                userId: userId,
                                title: title,
                                description: description,
                                priority: priority,
                                categoryId: selectedCategory?.id,
                                dueDate: hasDueDate ? dueDate : nil
                            )

                            // ✅ Step 2: create each subtask using the new task id
                            if let newTask = viewModel.tasks.last, !subtaskTitles.isEmpty {
                                let subtaskVM = SubtaskViewModel(taskId: newTask.id)
                                for (index, subtaskTitle) in subtaskTitles.enumerated() {
                                    await subtaskVM.createSubtask(title: subtaskTitle)
                                    _ = index // suppress unused warning
                                }
                            }

                            dismiss()
                        }
                    } label: {
                        Text("Add")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(title.isEmpty ? .secondary : .black)
                    }
                    .disabled(title.isEmpty)
                }
            }
            // ✅ All sheets unchanged
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
            // ✅ unchanged task fetching
            .task {
                if let userId = authService.currentUser?.id {
                    await categoryViewModel.fetchCategories(for: userId)
                    await tagViewModel.fetchTags(for: userId)
                }
            }
        }
    }

    private func addSubtaskTitle() {
        let trimmed = newSubtaskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        subtaskTitles.append(trimmed)
        newSubtaskTitle = ""
    }
    // MARK: - UI Helpers
    private func formCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading) {
            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    private func cardLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .tracking(2)
            .foregroundColor(.secondary)
    }
}

// MARK: - FlowLayout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: frame.minX + bounds.minX, y: frame.minY + bounds.minY), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            var maxX: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth, x > 0 {
                    y += rowHeight + spacing
                    x = 0
                    rowHeight = 0
                }
                frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
                x += size.width + spacing
                rowHeight = max(rowHeight, size.height)
                maxX = max(maxX, x)
            }
            self.size = CGSize(width: maxX, height: y + rowHeight)
        }
    }
}
