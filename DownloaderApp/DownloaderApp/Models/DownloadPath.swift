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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle ID as Int or String
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            self.id = idInt
        } else if let idString = try? container.decode(String.self, forKey: .id), let idInt = Int(idString) {
            self.id = idInt
        } else {
            throw DecodingError.typeMismatch(Int.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Expected Int or String for id"))
        }
        
        self.name = try container.decode(String.self, forKey: .name)
        self.path = try container.decode(String.self, forKey: .path)
        
        // Handle isDefault from multiple possible keys
        if let isDefault = try? container.decode(Bool.self, forKey: .isDefault) {
            self.isDefault = isDefault
        } else {
            // Fallback to manual decoding for other keys if CodingKeys didn't match
            let rawContainer = try decoder.container(keyedBy: GenericCodingKeys.self)
            if let isDefault = try? rawContainer.decode(Bool.self, forKey: GenericCodingKeys(stringValue: "is_default")!) {
                self.isDefault = isDefault
            } else if let isDefault = try? rawContainer.decode(Bool.self, forKey: GenericCodingKeys(stringValue: "isDefault")!) {
                self.isDefault = isDefault
            } else {
                // Default to false if missing (robustness)
                self.isDefault = false
            }
        }
    }
    
    struct GenericCodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { return nil }
    }
    
    // Default init for previews/tests
    init(id: Int, name: String, path: String, isDefault: Bool) {
        self.id = id
        self.name = name
        self.path = path
        self.isDefault = isDefault
    }
}
