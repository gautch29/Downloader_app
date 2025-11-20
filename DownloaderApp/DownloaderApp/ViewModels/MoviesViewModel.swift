//
//  MoviesViewModel.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation
import SwiftUI

@MainActor
class MoviesViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private let movieService = MovieService.shared
    private let downloadService = DownloadService.shared
    
    // Debounce search
    private var searchTask: Task<Void, Never>?
    
    func search(query: String) {
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            movies = []
            return
        }
        
        searchTask = Task {
            // Debounce
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
            
            if Task.isCancelled { return }
            
            await performSearch(query: query)
        }
    }
    
    private func performSearch(query: String) async {
        isLoading = true
        errorMessage = nil
        print("🔍 [ViewModel] Searching for: \(query)")
        
        do {
            movies = try await movieService.searchMovies(query: query)
            print("✅ [ViewModel] Found \(movies.count) movies")
        } catch {
            print("❌ [ViewModel] Search error: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func getLinks(for quality: MovieQuality) async -> String? {
        isLoading = true
        errorMessage = nil
        
        do {
            let links = try await movieService.getMovieLinks(url: quality.url)
            isLoading = false
            return links.first
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return nil
        }
    }
    
    func getLinksAndDownload(quality: MovieQuality, targetPath: String? = nil) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Get links
            let links = try await movieService.getMovieLinks(url: quality.url)
            
            guard let firstLink = links.first else {
                throw APIError.serverError("No download links found")
            }
            
            // 2. Add download
            // We use the first link found. In a more advanced version, we could let user choose if multiple.
            _ = try await downloadService.addDownload(
                url: firstLink,
                targetPath: targetPath
            )
            
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}
