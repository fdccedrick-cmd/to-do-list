//
//  EmptyStateView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI

struct EmptyStateView: View {
    let onAddTask: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checklist")
                .font(.system(size: 70))
                .foregroundStyle(.blue.gradient)
            
            Text("No Tasks Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Get started by adding your first task")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button {
                onAddTask()
            } label: {
                Label("Add Task", systemImage: "plus")
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}
