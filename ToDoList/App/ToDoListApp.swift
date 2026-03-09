//
//  ToDoListApp.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI

@main
struct ToDoListApp: App {
    @StateObject private var authService = AuthService()
    
    init() {
        // Initialize notification service on app launch
        _ = NotificationService.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .task {
                    // Request notification permissions on first launch
                    _ = await NotificationService.shared.requestAuthorization()
                }
        }
    }
}
