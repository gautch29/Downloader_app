//
//  SettingsService.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation

struct SettingsResponse: Codable {
    let settings: AppSettings
}

struct UpdateSettingsRequest: Codable {
    let plexUrl: String?
    let plexToken: String?
    let defaultPath: String?
}

struct UpdateSettingsResponse: Codable {
    let success: Bool
}

class SettingsService {
    static let shared = SettingsService()
    private let client = APIClient.shared
    
    private init() {}
    
    func getSettings() async throws -> AppSettings {
        let response: SettingsResponse = try await client.get(Constants.Endpoints.settings)
        return response.settings
    }
    
    func updateSettings(_ settings: AppSettings) async throws {
        let request = UpdateSettingsRequest(
            plexUrl: settings.plexUrl,
            plexToken: settings.plexToken,
            defaultPath: settings.defaultPath
        )
        let response: UpdateSettingsResponse = try await client.put(Constants.Endpoints.settings, body: request)
        
        if !response.success {
            throw APIError.serverError("Failed to update settings")
        }
    }
}
