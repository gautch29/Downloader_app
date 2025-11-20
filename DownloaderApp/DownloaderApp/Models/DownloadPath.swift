//
//  DownloadPath.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation

struct DownloadPath: Codable, Identifiable {
    let id: String
    let name: String
    let path: String
    
    // Backend doesn't have default field, so we'll track it locally
    var isDefault: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, name, path
    }
}
