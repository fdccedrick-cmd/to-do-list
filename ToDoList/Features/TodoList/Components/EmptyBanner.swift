//
//  EmptyBanner.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI

struct EmptyBanner: View {
    let icon: String
    let title: String
    let message: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(iconColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                Text(message)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    iconColor.opacity(0.08),
                    iconColor.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(iconColor.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        EmptyBanner(
            icon: "checkmark.circle.fill",
            title: "No overdue tasks 🎉",
            message: "You're all caught up!",
            iconColor: .green
        )
        
        EmptyBanner(
            icon: "moon.stars.fill",
            title: "All done for today!",
            message: "Time to relax",
            iconColor: .blue
        )
    }
    .padding()
    .background(Color(white: 0.96))
}
