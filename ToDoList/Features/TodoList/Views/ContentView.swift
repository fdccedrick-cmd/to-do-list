//
//  ContentView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        Group {
            if authService.isLoading {
                // Loading state while checking auth
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading...")
                        .foregroundStyle(.secondary)
                }
            } else if authService.isAuthenticated {
                // Main app view (authenticated)
                MainTabView()
            } else {
                // Show login screen
                LoginView()
            }
        }
        .task {
            await authService.checkAuthStatus()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService())
}
