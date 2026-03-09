//
//  AddReminderView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/9/26.
//

import SwiftUI
import Auth

struct AddReminderView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthService
    @ObservedObject var viewModel: ReminderViewModel
    
    let task: Task
    
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.96).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Task Info Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("TASK")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(2)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 12) {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(task.isCompleted ? .green : .secondary)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(task.title)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    if let dueDate = task.dueDate {
                                        Text("Due: \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        
                        // Reminder Date/Time Card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("REMINDER TIME")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(2)
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 12) {
                                // Quick preset options
                                quickPresetButton(title: "In 1 Hour", date: Date().addingTimeInterval(3600))
                                Divider().padding(.leading, 48)
                                quickPresetButton(title: "Tomorrow at 9 AM", date: tomorrowAt9AM())
                                Divider().padding(.leading, 48)
                                quickPresetButton(title: "In 1 Week", date: Date().addingTimeInterval(7 * 24 * 3600))
                                
                                if task.dueDate != nil {
                                    Divider().padding(.leading, 48)
                                    quickPresetButton(title: "At Due Date", date: task.dueDate!)
                                }
                            }
                            
                            Divider()
                            
                            // Custom date picker
                            Button {
                                showDatePicker.toggle()
                            } label: {
                                HStack {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 16))
                                        .foregroundColor(.blue)
                                    
                                    Text("Custom Time")
                                        .font(.system(size: 15))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: showDatePicker ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            
                            if showDatePicker {
                                DatePicker(
                                    "Select Date & Time",
                                    selection: $selectedDate,
                                    in: Date()...,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                            }
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        
                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("ADD REMINDER")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(3)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        _Concurrency.Task {
                            if let userId = authService.currentUser?.id {
                                await viewModel.createReminder(
                                    taskId: task.id,
                                    userId: userId,
                                    remindAt: selectedDate,
                                    taskTitle: task.title
                                )
                                dismiss()
                            }
                        }
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                    .disabled(selectedDate <= Date())
                }
            }
        }
    }
    
    private func quickPresetButton(title: String, date: Date) -> some View {
        Button {
            selectedDate = date
        } label: {
            HStack {
                Image(systemName: "bell")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if date > Date() {
                    Text(date.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                } else {
                    Text("Past date")
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                }
                
                if Calendar.current.isDate(selectedDate, inSameDayAs: date) &&
                   abs(selectedDate.timeIntervalSince(date)) < 60 {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func tomorrowAt9AM() -> Date {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let components = calendar.dateComponents([.year, .month, .day], from: tomorrow)
        return calendar.date(bySettingHour: 9, minute: 0, second: 0, of: calendar.date(from: components) ?? tomorrow) ?? tomorrow
    }
}

#Preview {
    AddReminderView(
        viewModel: ReminderViewModel(),
        task: Task(
            id: UUID(),
            userId: UUID(),
            categoryId: nil,
            title: "Sample Task",
            description: "Sample description",
            isCompleted: false,
            priority: .medium,
            dueDate: Date().addingTimeInterval(7 * 24 * 3600),
            dueTime: nil,
            completedAt: nil,
            sortOrder: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
    )
    .environmentObject(AuthService())
}
