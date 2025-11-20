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
            // Refresh paths to get updated default status
            await fetchPaths()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deletePath(_ path: DownloadPath) async {
        errorMessage = nil
        
        do {
            try await pathService.deletePath(id: path.id)
            paths.removeAll { $0.id == path.id }
        } catch {
            errorMessage = error.localizedDescription
            print("Failed to delete path: \(error)")
        }
    }
}

@MainActor
class FileBrowserViewModel: ObservableObject {
    @Published var currentPath: String = ""
    @Published var folders: [PathService.BrowserFolder] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let pathService = PathService.shared
    
    func loadPath(_ path: String? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            if let path = path {
                let response = try await pathService.browsePath(path: path)
                self.currentPath = response.currentPath
                self.folders = response.folders.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            } else {
                // Root level: fetch shortcuts
                let shortcuts = try await pathService.getPaths()
                self.currentPath = "" // Root
                self.folders = shortcuts.map { PathService.BrowserFolder(name: $0.name, path: $0.path) }
                    .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createFolder(name: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let newPath = try await pathService.createFolder(parentPath: currentPath, folderName: name)
            // Refresh current path to show the new folder
            await loadPath(currentPath)
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}
