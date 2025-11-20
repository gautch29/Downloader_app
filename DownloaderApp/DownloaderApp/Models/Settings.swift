//
//  Settings.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation

struct AppSettings: Codable {
    var plexUrl: String?
    var plexToken: String?
    var defaultPath: String?
    var plexConfigured: Bool?
    
    enum CodingKeys: String, CodingKey {
        case plexUrl
        case plexToken
        case defaultPath
        case plexConfigured
    }
}
