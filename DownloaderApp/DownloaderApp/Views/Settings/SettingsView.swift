//
//  SettingsView.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingLogoutConfirmation = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Plex URL", text: Binding(
                        get: { viewModel.settings.plexUrl ?? "" },
                        set: { viewModel.settings.plexUrl = $0.isEmpty ? nil : $0 }
                    ))
                    .textContentType(.URL)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    
                    TextField("Plex Token", text: Binding(
                        get: { viewModel.settings.plexToken ?? "" },
                        set: { viewModel.settings.plexToken = $0.isEmpty ? nil : $0 }
                    ))
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                } header: {
                    Text("Plex Integration")
                } footer: {
                    Text("Configure Plex to automatically scan new downloads")
                }
                
                Section {
                    NavigationLink {
                        PathsView()
                    } label: {
                        Label("Manage Download Paths", systemImage: "folder")
                    }
                } header: {
                    Text("Configuration")
                }
                
                Section {
                    Button {
                        Task {
                            _ = await viewModel.saveSettings()
                        }
                    } label: {
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Save Settings")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(viewModel.isLoading)
                    
                    if let successMessage = viewModel.successMessage {
                        Text(successMessage)
                            .foregroundStyle(.green)
                            .frame(maxWidth: .infinity)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                Section {
                    if let user = authViewModel.currentUser {
                        HStack {
                            Text("Logged in as")
                            Spacer()
                            Text(user.username)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Button(role: .destructive) {
                        showingLogoutConfirmation = true
                    } label: {
                        Text("Logout")
                            .frame(maxWidth: .infinity)
                    }
                } header: {
                    Text("Account")
                }
                

                
                Section {
                    TextField("Server URL", text: Binding(
                        get: { UserDefaults.standard.string(forKey: "api_base_url") ?? Constants.defaultBaseURL },
                        set: { UserDefaults.standard.set($0, forKey: "api_base_url") }
                    ))
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    
                    Button("Reset to Default") {
                        UserDefaults.standard.removeObject(forKey: "api_base_url")
                    }
                    .disabled(UserDefaults.standard.string(forKey: "api_base_url") == nil)
                } header: {
                    Text("Server Configuration")
                } footer: {
                    Text("Restart app after changing server URL")
                }
            }
            .navigationTitle("Settings")
            .task {
                await viewModel.fetchSettings()
            }
            .confirmationDialog("Logout", isPresented: $showingLogoutConfirmation) {
                Button("Logout", role: .destructive) {
                    Task {
                        await authViewModel.logout()
                    }
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
