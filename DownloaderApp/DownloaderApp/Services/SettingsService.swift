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
    let fichierApiKey: String?
    let plexUrl: String?
    let plexToken: String?
    
    enum CodingKeys: String, CodingKey {
        case fichierApiKey = "1fichier_api_key"
        case plexUrl = "plex_url"
        case plexToken = "plex_token"
    }
}

struct UpdateSettingsResponse: Codable {
    let success: Bool
    let message: String?
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
            fichierApiKey: settings.fichierApiKey,
            plexUrl: settings.plexUrl,
            plexToken: settings.plexToken
        )
        let response: UpdateSettingsResponse = try await client.put(Constants.Endpoints.settings, body: request)
        
        if !response.success {
            throw APIError.serverError(response.message ?? "Failed to update settings")
        }
    }
}
