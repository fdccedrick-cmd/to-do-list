//
//  QuickStatsRow.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI

struct QuickStatsRow: View {
    let upcomingCount: Int
    let completedCount: Int
    let overdueCount: Int
    
    var body: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Upcoming",
                count: upcomingCount,
                icon: "calendar.badge.clock",
                color: .blue
            )
            
            StatCard(
                title: "Completed",
                count: completedCount,
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            StatCard(
                title: "Overdue",
                count: overdueCount,
                icon: "exclamationmark.triangle.fill",
                color: .red
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [Color.white, Color(white: 0.98)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    QuickStatsRow(
        upcomingCount: 5,
        completedCount: 3,
        overdueCount: 1
    )
    .padding()
    .background(Color(white: 0.96))
}
