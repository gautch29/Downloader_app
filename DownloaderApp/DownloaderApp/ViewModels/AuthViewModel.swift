//
//  AuthViewModel.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService = AuthService.shared
    
    init() {
        Task {
            await checkSession()
        }
    }
    
    func login(username: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.login(username: username, password: password)
            currentUser = user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() async {
        isLoading = true
        
        do {
            try await authService.logout()
            currentUser = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func checkSession() async {
        do {
            if let user = try await authService.checkSession() {
                currentUser = user
                isAuthenticated = true
            } else {
                isAuthenticated = false
            }
        } catch {
            isAuthenticated = false
        }
    }
}
