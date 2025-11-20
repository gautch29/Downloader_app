//
//  DownloaderApp.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import SwiftUI

@main
struct DownloaderApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
