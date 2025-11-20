//
//  PathsViewModel.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation
import SwiftUI

@MainActor
class PathsViewModel: ObservableObject {
    @Published var paths: [DownloadPath] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let pathService = PathService.shared
    
    var defaultPath: DownloadPath? {
        paths.first { $0.isDefault }
    }
    
    func fetchPaths() async {
        isLoading = true
        errorMessage = nil
        
        do {
            paths = try await pathService.getPaths()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func addPath(name: String, path: String) async -> Bool {
        errorMessage = nil
        
        do {
            let newPath = try await pathService.addPath(name: name, path: path)
            paths.append(newPath)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func setDefaultPath(_ path: DownloadPath) async {
        errorMessage = nil
        
        do {
            try await pathService.setDefaultPath(id: path.id)
            // Update local state
            paths = paths.map { p in
                var updated = p
                updated.isDefault = (p.id == path.id)
                return updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deletePath(_ path: DownloadPath) async {
        errorMessage = nil
        
        // Optimistically remove from UI
        let originalPaths = paths
        paths.removeAll { $0.id == path.id }
        
        do {
            try await pathService.deletePath(name: path.name)
            // Successfully deleted, refresh to ensure sync with backend
            await fetchPaths()
        } catch {
            // Restore on error
            paths = originalPaths
            errorMessage = error.localizedDescription
        }
    }
}
