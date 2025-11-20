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
    let customFilename: String?
    let targetPath: String?
}

struct AddDownloadResponse: Codable {
    let success: Bool
    let download: Download?
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
    
    func addDownload(url: String, targetPath: String? = nil, customFilename: String? = nil) async throws -> Download {
        let request = AddDownloadRequest(url: url, customFilename: customFilename, targetPath: targetPath)
        let response: AddDownloadResponse = try await client.post(Constants.Endpoints.downloads, body: request)
        
        if response.success, let download = response.download {
            return download
        } else {
            throw APIError.serverError(response.message ?? "Failed to add download")
        }
    }
    
    func cancelDownload(id: Int) async throws {
        // Backend doesn't have cancel endpoint in the docs, so this might not work
        // We'll just make a DELETE request and see
        let endpoint = "\(Constants.Endpoints.downloads)/\(id)"
        struct EmptyResponse: Codable {}
        let _: EmptyResponse = try await client.delete(endpoint)
    }
    
    func getDownloadDetails(id: Int) async throws -> Download {
        let endpoint = "\(Constants.Endpoints.downloads)/\(id)"
        return try await client.get(endpoint)
    }
}
