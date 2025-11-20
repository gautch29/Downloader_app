//
//  LoginView.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Logo/Title
                VStack(spacing: 8) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue.gradient)
                    
                    Text("Downloader")
                        .font(.largeTitle.bold())
                }
                .padding(.bottom, 40)
                
                // Login Form
                VStack(spacing: 16) {
                    TextField("Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Button {
                        Task {
                            await viewModel.login(username: username, password: password)
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Text("Login")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue.gradient)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(username.isEmpty || password.isEmpty || viewModel.isLoading)
                }
                
                Spacer()
            }
            .padding(32)
            .navigationTitle("Login")
        }
    }
}

#Preview {
    LoginView()
}
