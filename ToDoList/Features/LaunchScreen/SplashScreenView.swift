//
//  SplashScreenView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/9/26.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var fadeIn = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.black, Color(white: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // App Icon/Logo
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                }
                .shadow(color: .white.opacity(0.3), radius: 20, x: 0, y: 10)
                
                // App Name
                VStack(spacing: 8) {
                    Text("ToDoList")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Stay Organized, Get Things Done")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .tracking(1)
                }
                .opacity(fadeIn ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            
            withAnimation(.easeIn(duration: 0.8).delay(0.2)) {
                fadeIn = true
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
