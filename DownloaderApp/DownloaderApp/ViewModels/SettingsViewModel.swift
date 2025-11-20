//
//  SettingsViewModel.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var settings = AppSettings()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let settingsService = SettingsService.shared
    
    func fetchSettings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            settings = try await settingsService.getSettings()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func saveSettings() async -> Bool {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            try await settingsService.updateSettings(settings)
            successMessage = "Settings saved successfully"
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
        
        isLoading = false
    }
}
