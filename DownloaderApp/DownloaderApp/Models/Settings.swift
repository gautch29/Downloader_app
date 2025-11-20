//
//  Settings.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation

struct AppSettings: Codable {
    var fichierApiKey: String?
    var plexUrl: String?
    var plexToken: String?
    
    enum CodingKeys: String, CodingKey {
        case fichierApiKey = "1fichier_api_key"
        case plexUrl = "plex_url"
        case plexToken = "plex_token"
    }
}

struct SettingItem: Codable {
    let key: String
    let value: String
}
