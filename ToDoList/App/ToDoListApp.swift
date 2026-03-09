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
    @State private var showSplashScreen = true
    
    init() {
        // Initialize notification service on app launch
        _ = NotificationService.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplashScreen {
                    SplashScreenView()
                        .transition(.opacity)
                } else {
                    ContentView()
                        .environmentObject(authService)
                        .task {
                            // Request notification permissions on first launch
                            _ = await NotificationService.shared.requestAuthorization()
                        }
                }
            }
            .onAppear {
                // Hide splash screen after 2.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplashScreen = false
                    }
                }
            }
        }
    }
}
