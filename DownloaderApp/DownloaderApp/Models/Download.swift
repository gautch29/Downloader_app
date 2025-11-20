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
    let status: DownloadStatus
    let progress: Double?
    let size: Int64?
    let speed: Int64?
    let addedAt: Date
    let startedAt: Date?
    let completedAt: Date?
    let errorMessage: String?
    let pathId: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, url, filename, status, progress, size, speed
        case addedAt = "added_at"
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case errorMessage = "error_message"
        case pathId = "path_id"
    }
    
    var progressPercentage: Int {
        guard let progress = progress else { return 0 }
        return Int(progress * 100)
    }
    
    var formattedSize: String {
        guard let size = size else { return "Unknown" }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    var formattedSpeed: String {
        guard let speed = speed else { return "" }
        return "\(ByteCountFormatter.string(fromByteCount: speed, countStyle: .file))/s"
    }
    
    var displayFilename: String {
        filename ?? "Detecting filename..."
    }
}
