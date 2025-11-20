//
//  FileBrowserViewModel.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation
import SwiftUI

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
            let response = try await pathService.browsePath(path: path)
            self.currentPath = response.currentPath
            self.folders = response.folders.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
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
