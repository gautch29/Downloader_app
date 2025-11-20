//
//  Download.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation

struct Download: Codable, Identifiable {
    let id: Int
    let url: String
    let filename: String?
    let customFilename: String?
    let status: DownloadStatus
    let progress: Double? // 0.0-1.0
    let size: Int64? // bytes
    let speed: Int64? // bytes/sec
    let addedAt: Date
    let startedAt: Date?
    let completedAt: Date?
    let errorMessage: String?
    let pathId: Int?
    let targetPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id, url, filename, status, progress, size, speed
        case customFilename = "customFilename"
        case targetPath = "targetPath"
        case addedAt = "createdAt"
        case startedAt = "updatedAt" // Mapping startedAt to updatedAt as it seems to be the closest equivalent
        case completedAt = "completed_at" // Keep this if backend adds it later, or make optional
        case errorMessage = "error" // Backend returns "error" key
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
        
        self.url = try container.decode(String.self, forKey: .url)
        self.filename = try container.decodeIfPresent(String.self, forKey: .filename)
        self.customFilename = try container.decodeIfPresent(String.self, forKey: .customFilename)
        self.status = try container.decode(DownloadStatus.self, forKey: .status)
        self.progress = try container.decodeIfPresent(Double.self, forKey: .progress)
        self.size = try container.decodeIfPresent(Int64.self, forKey: .size)
        self.speed = try container.decodeIfPresent(Int64.self, forKey: .speed)
        self.addedAt = try container.decode(Date.self, forKey: .addedAt)
        self.startedAt = try container.decodeIfPresent(Date.self, forKey: .startedAt)
        self.completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
        self.errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        
        // pathId is removed/ignored as backend uses targetPath
        self.pathId = nil
        
        self.targetPath = try container.decodeIfPresent(String.self, forKey: .targetPath)
    }
    
    // Default init for previews/tests
    init(id: Int, url: String, filename: String? = nil, customFilename: String? = nil, status: DownloadStatus, progress: Double? = nil, size: Int64? = nil, speed: Int64? = nil, addedAt: Date, startedAt: Date? = nil, completedAt: Date? = nil, errorMessage: String? = nil, pathId: Int? = nil, targetPath: String? = nil) {
        self.id = id
        self.url = url
        self.filename = filename
        self.customFilename = customFilename
        self.status = status
        self.progress = progress
        self.size = size
        self.speed = speed
        self.addedAt = addedAt
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.errorMessage = errorMessage
        self.pathId = pathId
        self.targetPath = targetPath
    }
    
    var progressPercentage: Int {
        guard let progress = progress else { return 0 }
        return Int(progress * 100)
    }
    
    var formattedSpeed: String {
        guard let speed = speed else { return "" }
        return ByteCountFormatter.string(fromByteCount: speed, countStyle: .file) + "/s"
    }
    
    var formattedSize: String {
        guard let size = size else { return "" }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    var displayFilename: String {
        filename ?? "Detecting filename..."
    }
}
