//
//  LoginView.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var username = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case username, password
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Subtle gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.97, blue: 1.0),
                        Color(red: 0.92, green: 0.96, blue: 0.99)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 50) {
                        // Logo/Title
                        VStack(spacing: 20) {
                            // Liquid glass icon container
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 120, height: 120)
                                    .shadow(color: Color.blue.opacity(0.15), radius: 20, x: 0, y: 10)
                                
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.blue, Color.cyan],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            
                            Text("Downloader")
                                .font(.system(size: 36, weight: .semibold, design: .rounded))
                                .foregroundStyle(.primary)
                            
                            Text("Welcome back")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fontWeight(.medium)
                        }
                        .padding(.top, 80)
                        
                        // Login Form - Liquid glass card
                        VStack(spacing: 20) {
                            VStack(spacing: 16) {
                                CustomTextField(icon: "person.fill", placeholder: "Username", text: $username)
                                    .textContentType(.username)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .focused($focusedField, equals: .username)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = .password }
                                
                                CustomSecureField(icon: "lock.fill", placeholder: "Password", text: $password)
                                    .textContentType(.password)
                                    .focused($focusedField, equals: .password)
                                    .submitLabel(.go)
                                    .onSubmit {
                                        if !username.isEmpty && !password.isEmpty {
                                            login()
                                        }
                                    }
                            }
                            
                            if let errorMessage = viewModel.errorMessage {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                    Text(errorMessage)
                                }
                                .font(.caption)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                            }
                            
                            Button {
                                login()
                            } label: {
                                ZStack {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Sign In")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue, Color.cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: Color.blue.opacity(0.25), radius: 8, x: 0, y: 4)
                            }
                            .disabled(username.isEmpty || password.isEmpty || viewModel.isLoading)
                            .opacity(username.isEmpty || password.isEmpty || viewModel.isLoading ? 0.6 : 1)
                            .animation(.easeInOut(duration: 0.2), value: username.isEmpty || password.isEmpty || viewModel.isLoading)
                        }
                        .padding(28)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                        .padding(.horizontal, 24)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("")
        }
    }
    
    private func login() {
        Task {
            await viewModel.login(username: username, password: password)
        }
    }
}

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.7), Color.cyan.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 20)
                .font(.system(size: 16))
            
            TextField(placeholder, text: $text)
                .font(.body)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

struct CustomSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.7), Color.cyan.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 20)
                .font(.system(size: 16))
            
            SecureField(placeholder, text: $text)
                .font(.body)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
