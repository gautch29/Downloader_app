//
//  PathService.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation

struct PathsResponse: Codable {
    let paths: [DownloadPath]
}

struct AddPathRequest: Codable {
    let name: String
    let path: String
}

struct PathActionResponse: Codable {
    let success: Bool
}

class PathService {
    static let shared = PathService()
    private let client = APIClient.shared
    
    private init() {}
    
    func getPaths() async throws -> [DownloadPath] {
        let response: PathsResponse = try await client.get(Constants.Endpoints.paths)
        return response.paths
    }
    
    func addPath(name: String, path: String) async throws -> DownloadPath {
        let request = AddPathRequest(name: name, path: path)
        let response: PathActionResponse = try await client.post(Constants.Endpoints.paths, body: request)
        
        if response.success {
            // Backend doesn't return the created path, so create a temporary one
            return DownloadPath(id: UUID().uuidString, name: name, path: path)
        } else {
            throw APIError.serverError("Failed to add path")
        }
    }
    
    func setDefaultPath(id: String) async throws {
        // Backend doesn't have this endpoint, so we'll skip it
        // This feature won't work until backend adds support
    }
    
    func deletePath(name: String) async throws {
        // Backend uses query parameter for delete
        let endpoint = "\(Constants.Endpoints.paths)?name=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name)"
        let response: PathActionResponse = try await client.delete(endpoint)
        
        if !response.success {
            throw APIError.serverError("Failed to delete path")
        }
    }
}
