//
//  AuthService.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import Foundation
import SwiftUI
import Supabase
import Combine

class AuthService: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let supabase = SupabaseManager.shared.client
    
    init() {
        // Auth status will be checked in ContentView's .task modifier
    }
    
    // MARK: - Sign Up
    @MainActor
    func signUp(email: String, password: String, displayName: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // Trim whitespace from email
            let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            
            print("🔐 Attempting sign up with email: \(cleanEmail)")
            
            // Step 1: Sign up user
            let response = try await supabase.auth.signUp(
                email: cleanEmail,
                password: password
            )
            
            print("✅ Sign up response received")
            print("📧 User ID: \(response.user.id)")
            
            let user = response.user
            currentUser = user
            
            // Step 2: Create profile in database
            let profileInsert = ProfileInsert(
                id: user.id,
                displayName: displayName,
                timezone: TimeZone.current.identifier
            )
            
            do {
                print("📝 Creating profile in database...")
                try await supabase
                    .from("profiles")
                    .insert(profileInsert)
                    .execute()
                print("✅ Profile created successfully")
            } catch let profileError {
                // If profile creation fails, show specific error
                errorMessage = "Account created but profile setup failed: \(profileError.localizedDescription)"
                print("❌ Profile creation error: \(profileError)")
                print("❌ Full error: \(String(describing: profileError))")
                // Still mark as authenticated since the user account exists
            }
            
            isAuthenticated = true
        } catch let signUpError {
            let errorDesc = signUpError.localizedDescription
            errorMessage = errorDesc
            
            // Log detailed error for debugging
            print("❌ Sign up error: \(signUpError)")
            print("❌ Error description: \(errorDesc)")
            print("❌ Full error details: \(String(describing: signUpError))")
            
            // Provide more helpful error messages
            if errorDesc.contains("invalid") || errorDesc.contains("email") {
                errorMessage = "Please check your email format and try again"
            } else if errorDesc.contains("password") {
                errorMessage = "Password must be at least 6 characters"
            } else if errorDesc.contains("already") || errorDesc.contains("registered") {
                errorMessage = "This email is already registered. Try logging in instead."
            }
            
            throw signUpError
        }
    }
    
    // MARK: - Sign In
    @MainActor
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            currentUser = session.user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Sign Out
    @MainActor
    func signOut() async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await supabase.auth.signOut()
        currentUser = nil
        isAuthenticated = false
    }
    
    // MARK: - Check Auth Status
    @MainActor
    func checkAuthStatus() async {
        do {
            let session = try await supabase.auth.session
            
            // Check if session is expired
            if session.isExpired {
                print("⚠️ Session is expired, clearing auth state")
                currentUser = nil
                isAuthenticated = false
            } else {
                currentUser = session.user
                isAuthenticated = true
                print("✅ Valid session found for user: \(session.user.email ?? "unknown")")
            }
        } catch {
            print("ℹ️ No valid session found")
            currentUser = nil
            isAuthenticated = false
        }
    }
}
