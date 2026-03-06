//
//  SignUpView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

//
//  SignUpView.swift
//  ToDoList
//
//  Created by Cedrick Agtong - INTERN on 3/6/26.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss          // ✅ unchanged
    @EnvironmentObject var authService: AuthService // ✅ unchanged

    @State private var displayName = ""          // ✅ unchanged
    @State private var email = ""                // ✅ unchanged
    @State private var password = ""             // ✅ unchanged
    @State private var confirmPassword = ""      // ✅ unchanged

    // ✅ UI only states
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var animateIn = false
    @FocusState private var focusedField: Field?

    enum Field { case name, email, password, confirmPassword }

    var body: some View {
        ZStack {
            // ✅ Background
            Color(white: 0.96).ignoresSafeArea()

            // ✅ Decorative circles
            GeometryReader { geo in
                Circle()
                    .fill(Color.black.opacity(0.04))
                    .frame(width: 280, height: 280)
                    .offset(x: geo.size.width - 100, y: -60)
                    .blur(radius: 4)

                Circle()
                    .fill(Color.black.opacity(0.03))
                    .frame(width: 200, height: 200)
                    .offset(x: -60, y: geo.size.height - 180)
                    .blur(radius: 2)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // MARK: - Header
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
                        .padding(.top, 60)

                        Text("TODOLIST")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(3.5)
                            .foregroundColor(.secondary)
                    }
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : -20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateIn)

                    // MARK: - Welcome Text
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Create")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.primary)

                        Text("account.")
                            .font(.system(size: 44, weight: .light))
                            .italic()
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 36)
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : -14)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateIn)

                    Spacer().frame(height: 40)

                    // MARK: - Form
                    VStack(spacing: 28) {

                        // Display Name
                        inputField(
                            label: "DISPLAY NAME",
                            placeholder: "Enter your name",
                            icon: "person",
                            field: .name,
                            text: $displayName,
                            contentType: .name,
                            keyboard: .default,
                            submitLabel: .next,
                            onSubmit: { focusedField = .email }
                        )

                        // Email
                        inputField(
                            label: "EMAIL ADDRESS",
                            placeholder: "Enter your email",
                            icon: "envelope",
                            field: .email,
                            text: $email,
                            contentType: .emailAddress,
                            keyboard: .emailAddress,
                            submitLabel: .next,
                            onSubmit: { focusedField = .password }
                        )

                        // Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PASSWORD")
                                .font(.system(size: 10, weight: .semibold))
                                .tracking(2)
                                .foregroundColor(.secondary)

                            HStack(spacing: 12) {
                                Image(systemName: "lock")
                                    .font(.system(size: 14))
                                    .foregroundColor(focusedField == .password ? .black : .secondary)
                                    .animation(.easeInOut(duration: 0.2), value: focusedField)

                                // ✅ unchanged binding
                                Group {
                                    if showPassword {
                                        TextField("Enter your password", text: $password)
                                    } else {
                                        SecureField("Enter your password", text: $password)
                                            .textContentType(.newPassword) // ✅ unchanged
                                    }
                                }
                                .font(.system(size: 15))
                                .focused($focusedField, equals: .password)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .confirmPassword }

                                Button { showPassword.toggle() } label: {
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

                            // ✅ unchanged hint
                            Text("Minimum 6 characters")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }

                        // Confirm Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CONFIRM PASSWORD")
                                .font(.system(size: 10, weight: .semibold))
                                .tracking(2)
                                .foregroundColor(.secondary)

                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(focusedField == .confirmPassword ? .black : .secondary)
                                    .animation(.easeInOut(duration: 0.2), value: focusedField)

                                // ✅ unchanged binding
                                Group {
                                    if showConfirmPassword {
                                        TextField("Confirm your password", text: $confirmPassword)
                                    } else {
                                        SecureField("Confirm your password", text: $confirmPassword)
                                            .textContentType(.newPassword) // ✅ unchanged
                                    }
                                }
                                .font(.system(size: 15))
                                .focused($focusedField, equals: .confirmPassword)
                                .submitLabel(.done)
                                .onSubmit { focusedField = nil }

                                Button { showConfirmPassword.toggle() } label: {
                                    Image(systemName: showConfirmPassword ? "eye" : "eye.slash")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.bottom, 10)
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(
                                        !confirmPassword.isEmpty && password != confirmPassword
                                            ? Color.red
                                            : focusedField == .confirmPassword
                                                ? Color.black
                                                : Color(.systemGray4)
                                    )
                                    .frame(height: focusedField == .confirmPassword ? 1.5 : 0.8)
                                    .animation(.easeInOut(duration: 0.2), value: focusedField)
                            }

                            // ✅ unchanged validation
                            if !confirmPassword.isEmpty && password != confirmPassword {
                                HStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 11))
                                    Text("Passwords do not match")
                                        .font(.system(size: 11))
                                }
                                .foregroundColor(.red)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }

                        // ✅ unchanged error
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

                    // MARK: - Sign Up Button — ✅ unchanged action
                    Button(action: {
                        focusedField = nil
                        _Concurrency.Task {
                            try? await authService.signUp(   // ✅ unchanged
                                email: email,
                                password: password,
                                displayName: displayName
                            )
                        }
                    }) {
                        ZStack {
                            if authService.isLoading {
                                ProgressView()              // ✅ unchanged
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                                    .scaleEffect(0.9)
                            } else {
                                HStack(spacing: 8) {
                                    Text("Create Account")
                                        .font(.system(size: 16, weight: .semibold))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(isFormValid ? Color.black : Color(.systemGray3)) // ✅ unchanged isFormValid
                        .clipShape(Capsule())
                        .shadow(
                            color: isFormValid ? .black.opacity(0.2) : .clear,
                            radius: 12, x: 0, y: 6
                        )
                        .animation(.easeInOut(duration: 0.2), value: isFormValid)
                    }
                    .disabled(!isFormValid || authService.isLoading) // ✅ unchanged
                    .opacity(animateIn ? 1 : 0)
                    .animation(.spring(response: 0.6).delay(0.4), value: animateIn)

                    Spacer().frame(height: 28)

                    // MARK: - Login Link — ✅ unchanged
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)

                        Button("Sign In") {
                            dismiss() // ✅ unchanged
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
        // ✅ Removed nav bar — matches LoginView style
        .navigationBarHidden(true)
        .onAppear { animateIn = true }
        .onTapGesture { focusedField = nil }
    }

    // MARK: - Reusable Input Field helper (UI only)
    private func inputField(
        label: String,
        placeholder: String,
        icon: String,
        field: Field,
        text: Binding<String>,
        contentType: UITextContentType,
        keyboard: UIKeyboardType,
        submitLabel: SubmitLabel,
        onSubmit: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .tracking(2)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(focusedField == field ? .black : .secondary)
                    .animation(.easeInOut(duration: 0.2), value: focusedField)

                TextField(placeholder, text: text)
                    .font(.system(size: 15))
                    .textContentType(contentType)
                    .textInputAutocapitalization(
                        keyboard == .emailAddress ? .never : .words
                    )
                    .keyboardType(keyboard)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: field)
                    .submitLabel(submitLabel)
                    .onSubmit(onSubmit)
            }
            .padding(.bottom, 10)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(focusedField == field ? Color.black : Color(.systemGray4))
                    .frame(height: focusedField == field ? 1.5 : 0.8)
                    .animation(.easeInOut(duration: 0.2), value: focusedField)
            }
        }
    }

    // ✅ completely unchanged
    private var isFormValid: Bool {
        !displayName.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        password.count >= 6 &&
        password == confirmPassword
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthService()) // ✅ unchanged
}
