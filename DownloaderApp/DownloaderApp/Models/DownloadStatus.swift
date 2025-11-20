//
//  DownloadStatus.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation

enum DownloadStatus: String, Codable, CaseIterable {
    case pending
    case downloading
    case completed
    case error
    case cancelled
    case paused
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .downloading: return "Downloading"
        case .completed: return "Completed"
        case .error: return "Error"
        case .cancelled: return "Cancelled"
        case .paused: return "Paused"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "gray"
        case .downloading: return "blue"
        case .completed: return "green"
        case .error: return "red"
        case .cancelled: return "orange"
        case .paused: return "yellow"
        }
    }
}
