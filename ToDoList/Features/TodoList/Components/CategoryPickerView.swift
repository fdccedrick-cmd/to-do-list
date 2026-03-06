//
//  CategoryPickerView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI

struct CategoryPickerView: View {
    @Environment(\.dismiss) var dismiss          // ✅ unchanged
    let categories: [Category]                   // ✅ unchanged
    @Binding var selectedCategory: Category?     // ✅ unchanged

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.96).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {

                        // ✅ None option — unchanged logic
                        categoryRow(
                            icon: "slash.circle",
                            iconColor: .secondary,
                            name: "None",
                            colorHex: nil,
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil  // ✅ unchanged
                            dismiss()
                        }

                        // ✅ unchanged ForEach
                        ForEach(categories) { category in
                            categoryRow(
                                icon: category.icon,
                                iconColor: Color(hex: category.colorHex),
                                name: category.name,
                                colorHex: category.colorHex,
                                isSelected: selectedCategory?.id == category.id
                            ) {
                                selectedCategory = category  // ✅ unchanged
                                dismiss()
                            }
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("CATEGORY")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(3)
                }

                // ✅ unchanged action
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private func categoryRow(
        icon: String,
        iconColor: Color,
        name: String,
        colorHex: String?,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 40, height: 40)

                    // emoji vs SF symbol
                    if icon.count == 1 || icon.unicodeScalars.first?.properties.isEmoji == true {
                        Text(icon)
                            .font(.system(size: 20))
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundColor(iconColor)
                    }
                }

                Text(name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()

                if let hex = colorHex {
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 10, height: 10)
                }

                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.black : Color(.systemGray4), lineWidth: 1.5)
                        .frame(width: 22, height: 22)

                    if isSelected {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.black.opacity(0.15) : Color.clear, lineWidth: 1)
            )
        }
    }
}
