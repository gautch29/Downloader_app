//
//  DownloadPath.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation

struct DownloadPath: Codable, Identifiable {
    let id: Int
    let name: String
    let path: String
    let isDefault: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, path
        case isDefault = "default"
    }
}
