//
//  Download.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation

struct Download: Codable, Identifiable {
    let id: String
    let url: String
    let filename: String?
    let status: DownloadStatus
    let progress: Int? // 0-100 percentage
    let speed: String? // Already formatted string like "1.5 MB/s"
    let targetPath: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, url, filename, status, progress, speed
        case targetPath
        case createdAt
        case updatedAt
    }
    
    var progressPercentage: Int {
        progress ?? 0
    }
    
    var progressDecimal: Double {
        Double(progress ?? 0) / 100.0
    }
    
    var formattedSpeed: String {
        speed ?? ""
    }
    
    var displayFilename: String {
        filename ?? "Detecting filename..."
    }
    
    // For compatibility with views that expect addedAt
    var addedAt: Date {
        createdAt
    }
}
