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

struct AddPathResponse: Codable {
    let success: Bool
    let path: DownloadPath?
    let message: String?
}

struct SetDefaultPathRequest: Codable {
    let id: Int
}

struct PathActionResponse: Codable {
    let success: Bool
    let message: String?
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
        let response: AddPathResponse = try await client.post(Constants.Endpoints.paths, body: request)
        
        if response.success, let path = response.path {
            return path
        } else {
            throw APIError.serverError(response.message ?? "Failed to add path")
        }
    }
    
    func setDefaultPath(id: Int) async throws {
        let endpoint = "\(Constants.Endpoints.paths)/\(id)/default"
        let response: PathActionResponse = try await client.put(endpoint, body: ["id": id])
        
        if !response.success {
            throw APIError.serverError(response.message ?? "Failed to set default path")
        }
    }
    
    func deletePath(id: Int) async throws {
        let endpoint = "\(Constants.Endpoints.paths)/\(id)"
        let response: PathActionResponse = try await client.delete(endpoint)
        
        if !response.success {
            throw APIError.serverError(response.message ?? "Failed to delete path")
        }
    }
}
