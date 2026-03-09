//
//  LoginView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

//
//  LoginView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService

    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showPassword = false       
    @State private var animateIn = false           
    @FocusState private var focusedField: Field? 

    enum Field { case email, password }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.96).ignoresSafeArea()
                GeometryReader { geo in
                    Circle()
                        .fill(Color.black.opacity(0.04))
                        .frame(width: 320, height: 320)
                        .offset(x: geo.size.width - 120, y: -100)
                        .blur(radius: 4)

                    Circle()
                        .fill(Color.black.opacity(0.03))
                        .frame(width: 220, height: 220)
                        .offset(x: -70, y: geo.size.height - 220)
                        .blur(radius: 2)
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // MARK: Logo
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 68, height: 68)
                                    .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 4)

                                Image(systemName: "checklist")
                                    .font(.system(size: 26, weight: .medium))
                                    .foregroundColor(.black)
                            }
                            .padding(.top, 70)

                            Text("TODOLIST")
                                .font(.system(size: 11, weight: .semibold))
                                .tracking(3.5)
                                .foregroundColor(.secondary)
                        }
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : -20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateIn)

                        // MARK: Welcome Text
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Welcome")
                                .font(.system(size: 44, weight: .bold))
                                .foregroundColor(.primary)

                            Text("back.")
                                .font(.system(size: 44, weight: .light))
                                .italic()
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 40)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : -14)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateIn)

                        Spacer().frame(height: 44)

                        // MARK: Form
                        VStack(spacing: 28) {
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("EMAIL ADDRESS")
                                    .font(.system(size: 10, weight: .semibold))
                                    .tracking(2)
                                    .foregroundColor(.secondary)

                                HStack(spacing: 12) {
                                    Image(systemName: "envelope")
                                        .font(.system(size: 14))
                                        .foregroundColor(focusedField == .email ? .black : .secondary)
                                        .animation(.easeInOut(duration: 0.2), value: focusedField)

                                    TextField("Enter your email", text: $email)
                                        .font(.system(size: 15))
                                        .textContentType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                        .keyboardType(.emailAddress)
                                        .autocorrectionDisabled()
                                        .focused($focusedField, equals: .email)
                                        .submitLabel(.next)
                                        .onSubmit { focusedField = .password }
                                }
                                .padding(.bottom, 10)
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .fill(focusedField == .email ? Color.black : Color(.systemGray4))
                                        .frame(height: focusedField == .email ? 1.5 : 0.8)
                                        .animation(.easeInOut(duration: 0.2), value: focusedField)
                                }
                            }

                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("PASSWORD")
                                        .font(.system(size: 10, weight: .semibold))
                                        .tracking(2)
                                        .foregroundColor(.secondary)

                                    Spacer()

                                    Button("FORGOT?") {}
                                        .font(.system(size: 10, weight: .semibold))
                                        .tracking(1.5)
                                        .foregroundColor(.secondary)
                                }

                                HStack(spacing: 12) {
                                    Image(systemName: "lock")
                                        .font(.system(size: 14))
                                        .foregroundColor(focusedField == .password ? .black : .secondary)
                                        .animation(.easeInOut(duration: 0.2), value: focusedField)
                                    Group {
                                        if showPassword {
                                            TextField("Enter your password", text: $password)
                                        } else {
                                            SecureField("Enter your password", text: $password)
                                                .textContentType(.password)
                                        }
                                    }
                                    .font(.system(size: 15))
                                    .focused($focusedField, equals: .password)
                                    .submitLabel(.done)
                                    .onSubmit { focusedField = nil }

                                    Button {
                                        showPassword.toggle()
                                    } label: {
                                        Image(systemName: showPassword ? "eye" : "eye.slash")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.bottom, 10)
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .fill(focusedField == .password ? Color.black : Color(.systemGray4))
                                        .frame(height: focusedField == .password ? 1.5 : 0.8)
                                        .animation(.easeInOut(duration: 0.2), value: focusedField)
                                }
                            }
                            if let errorMessage = authService.errorMessage {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 12))
                                    Text(errorMessage)
                                        .font(.system(size: 12))
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateIn)
                        .animation(.spring(response: 0.3), value: authService.errorMessage)

                        Spacer().frame(height: 36)

                        // MARK: Login Button 
                        Button(action: {
                            focusedField = nil
                            _Concurrency.Task {
                                try? await authService.signIn(email: email, password: password)
                            }
                        }) {
                            ZStack {
                                if authService.isLoading {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(.white)
                                        .scaleEffect(0.9)
                                } else {
                                    HStack(spacing: 8) {
                                        Text("Sign In")
                                            .font(.system(size: 16, weight: .semibold))
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(isFormValid ? Color.black : Color(.systemGray3))
                            .clipShape(Capsule())
                            .shadow(
                                color: isFormValid ? .black.opacity(0.2) : .clear,
                                radius: 12, x: 0, y: 6
                            )
                            .animation(.easeInOut(duration: 0.2), value: isFormValid)
                        }
                        .disabled(!isFormValid || authService.isLoading)
                        .opacity(animateIn ? 1 : 0)
                        .animation(.spring(response: 0.6).delay(0.4), value: animateIn)

                        Spacer().frame(height: 28)

                        // MARK: Sign Up Link 
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)

                            Button("Sign Up") {
                                showSignUp = true  
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        }
                        .opacity(animateIn ? 1 : 0)
                        .animation(.easeIn.delay(0.5), value: animateIn)

                        Spacer().frame(height: 50)
                    }
                    .padding(.horizontal, 28)
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSignUp) {
                SignUpView()         
            }
            .onAppear { animateIn = true }
            .onTapGesture { focusedField = nil }
        }
    }
    private var isFormValid: Bool {
        !email.isEmpty && email.contains("@") && password.count >= 6
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService())
}
