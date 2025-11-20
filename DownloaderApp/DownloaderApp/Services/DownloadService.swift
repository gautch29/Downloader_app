//
//  DownloadService.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation

struct DownloadsResponse: Codable {
    let downloads: [Download]
}

struct AddDownloadRequest: Codable {
    let url: String
    let pathId: Int?
    
    enum CodingKeys: String, CodingKey {
        case url
        case pathId = "path_id"
    }
}

struct AddDownloadResponse: Codable {
    let success: Bool
    let download: Download?
    let message: String?
}

struct CancelDownloadResponse: Codable {
    let success: Bool
    let message: String?
}

class DownloadService {
    static let shared = DownloadService()
    private let client = APIClient.shared
    
    private init() {}
    
    func getDownloads() async throws -> [Download] {
        let response: DownloadsResponse = try await client.get(Constants.Endpoints.downloads)
        return response.downloads
    }
    
    func addDownload(url: String, pathId: Int? = nil) async throws -> Download {
        let request = AddDownloadRequest(url: url, pathId: pathId)
        let response: AddDownloadResponse = try await client.post(Constants.Endpoints.downloads, body: request)
        
        if response.success, let download = response.download {
            return download
        } else {
            throw APIError.serverError(response.message ?? "Failed to add download")
        }
    }
    
    func cancelDownload(id: Int) async throws {
        let endpoint = "\(Constants.Endpoints.downloads)/\(id)"
        let response: CancelDownloadResponse = try await client.delete(endpoint)
        
        if !response.success {
            throw APIError.serverError(response.message ?? "Failed to cancel download")
        }
    }
    
    func getDownloadDetails(id: Int) async throws -> Download {
        let endpoint = "\(Constants.Endpoints.downloads)/\(id)"
        return try await client.get(endpoint)
    }
}
