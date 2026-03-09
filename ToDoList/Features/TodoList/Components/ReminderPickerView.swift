//
//  ReminderPickerView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI

struct ReminderPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var reminderDates: [Date]
    let dueDate: Date
    
    @State private var selectedPreset: ReminderPreset?
    @State private var customDate = Date()
    @State private var showCustomPicker = false
    
    enum ReminderPreset: String, CaseIterable {
        case atDueTime = "At due time"
        case fiveMinBefore = "5 minutes before"
        case fifteenMinBefore = "15 minutes before"
        case thirtyMinBefore = "30 minutes before"
        case oneHourBefore = "1 hour before"
        case twoHoursBefore = "2 hours before"
        case oneDayBefore = "1 day before"
        case twoDaysBefore = "2 days before"
        case oneWeekBefore = "1 week before"
        
        func date(from dueDate: Date) -> Date {
            switch self {
            case .atDueTime:
                return dueDate
            case .fiveMinBefore:
                return dueDate.addingTimeInterval(-5 * 60)
            case .fifteenMinBefore:
                return dueDate.addingTimeInterval(-15 * 60)
            case .thirtyMinBefore:
                return dueDate.addingTimeInterval(-30 * 60)
            case .oneHourBefore:
                return dueDate.addingTimeInterval(-60 * 60)
            case .twoHoursBefore:
                return dueDate.addingTimeInterval(-2 * 60 * 60)
            case .oneDayBefore:
                return Calendar.current.date(byAdding: .day, value: -1, to: dueDate) ?? dueDate
            case .twoDaysBefore:
                return Calendar.current.date(byAdding: .day, value: -2, to: dueDate) ?? dueDate
            case .oneWeekBefore:
                return Calendar.current.date(byAdding: .day, value: -7, to: dueDate) ?? dueDate
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.96).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Preset reminders
                        VStack(alignment: .leading, spacing: 12) {
                            Text("QUICK REMINDERS")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(2)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                            
                            VStack(spacing: 0) {
                                ForEach(ReminderPreset.allCases, id: \.self) { preset in
                                    Button {
                                        addPresetReminder(preset)
                                    } label: {
                                        HStack {
                                            Image(systemName: "bell")
                                                .font(.system(size: 14))
                                                .foregroundColor(.orange)
                                            
                                            Text(preset.rawValue)
                                                .font(.system(size: 15))
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            let date = preset.date(from: dueDate)
                                            if date > Date() {
                                                Text(date.formatted(date: .abbreviated, time: .shortened))
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.secondary)
                                            } else {
                                                Text("Past date")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.red)
                                            }
                                            
                                            if reminderDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(.green)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                    }
                                    
                                    if preset != ReminderPreset.allCases.last {
                                        Divider().padding(.leading, 48)
                                    }
                                }
                            }
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                        }
                        
                        // Custom reminder
                        VStack(alignment: .leading, spacing: 12) {
                            Text("CUSTOM REMINDER")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(2)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                            
                            VStack(spacing: 12) {
                                Button {
                                    showCustomPicker.toggle()
                                } label: {
                                    HStack {
                                        Image(systemName: "calendar.badge.plus")
                                            .font(.system(size: 14))
                                            .foregroundColor(.blue)
                                        
                                        Text("Add Custom Time")
                                            .font(.system(size: 15))
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: showCustomPicker ? "chevron.up" : "chevron.down")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                }
                                
                                if showCustomPicker {
                                    VStack(spacing: 12) {
                                        DatePicker(
                                            "Custom Reminder",
                                            selection: $customDate,
                                            in: Date()...dueDate,
                                            displayedComponents: [.date, .hourAndMinute]
                                        )
                                        .datePickerStyle(.graphical)
                                        .tint(.black)
                                        
                                        Button {
                                            addCustomReminder()
                                        } label: {
                                            Text("Add This Reminder")
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(Color.black)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                    }
                                    .padding(16)
                                }
                            }
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Add Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func addPresetReminder(_ preset: ReminderPreset) {
        let date = preset.date(from: dueDate)
        guard date > Date() else { return }
        
        // Check if similar time already exists
        if !reminderDates.contains(where: { abs($0.timeIntervalSince(date)) < 60 }) {
            reminderDates.append(date)
            reminderDates.sort()
        }
    }
    
    private func addCustomReminder() {
        guard customDate > Date() else { return }
        
        if !reminderDates.contains(where: { abs($0.timeIntervalSince(customDate)) < 60 }) {
            reminderDates.append(customDate)
            reminderDates.sort()
        }
        
        showCustomPicker = false
    }
}

#Preview {
    ReminderPickerView(
        reminderDates: .constant([]),
        dueDate: Date().addingTimeInterval(86400)
    )
}
