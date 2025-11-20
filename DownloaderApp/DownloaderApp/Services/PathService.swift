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

struct DeletePathResponse: Codable {
    let success: Bool
}

struct SetDefaultPathResponse: Codable {
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
        struct AddPathResponse: Codable {
            let success: Bool
            let path: DownloadPath?
        }
        
        let response: AddPathResponse = try await client.post(Constants.Endpoints.paths, body: request)
        
        if response.success, let path = response.path {
            return path
        } else {
            throw APIError.serverError("Failed to add path")
        }
    }
    
    func deletePath(id: String) async throws {
        let endpoint = Constants.Endpoints.paths + "/\(id)"
        let response: DeletePathResponse = try await client.delete(endpoint)
        
        if !response.success {
            throw APIError.serverError("Failed to delete path")
        }
    }
    
    func setDefaultPath(id: String) async throws {
        let endpoint = Constants.Endpoints.paths + "/\(id)/default"
        struct EmptyBody: Codable {}
        let response: SetDefaultPathResponse = try await client.put(endpoint, body: EmptyBody())
        
        if !response.success {
            throw APIError.serverError("Failed to set default path")
        }
    }
    
    // MARK: - File Browser API
    
    struct BrowseResponse: Codable {
        let currentPath: String
        let folders: [BrowserFolder]
    }
    
    struct BrowserFolder: Codable, Identifiable {
        let name: String
        let path: String
        
        var id: String { path }
    }
    
    func browsePath(path: String? = nil) async throws -> BrowseResponse {
        var endpoint = Constants.Endpoints.paths + "/browse"
        if let path = path, let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            endpoint += "?path=\(encodedPath)"
        }
        
        return try await client.get(endpoint)
    }
    
    struct CreateFolderRequest: Codable {
        let parentPath: String
        let folderName: String
    }
    
    struct CreateFolderResponse: Codable {
        let success: Bool
        let path: String
    }
    
    func createFolder(parentPath: String, folderName: String) async throws -> String {
        let request = CreateFolderRequest(parentPath: parentPath, folderName: folderName)
        let response: CreateFolderResponse = try await client.post(Constants.Endpoints.paths + "/create-folder", body: request)
        
        if response.success {
            return response.path
        } else {
            throw APIError.serverError("Failed to create folder")
        }
    }
}
