//
//  SeriesViewModel.swift
//  DownloaderApp
//
//  Created on 2025-11-22.
//

import Foundation
import SwiftUI

@MainActor
class SeriesViewModel: ObservableObject {
    @Published var series: [Series] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private let seriesService = SeriesService.shared
    
    // Debounce search
    private var searchTask: Task<Void, Never>?
    
    func search(query: String) {
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            series = []
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
        print("🔍 [ViewModel] Searching for series: \(query)")
        
        do {
            series = try await seriesService.searchSeries(query: query)
            print("✅ [ViewModel] Found \(series.count) series")
        } catch {
            print("❌ [ViewModel] Search error: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func getEpisodes(for quality: SeriesQuality) async -> [Episode]? {
        isLoading = true
        errorMessage = nil
        
        do {
            let episodes = try await seriesService.getSeriesEpisodes(url: quality.url)
            isLoading = false
            return episodes
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return nil
        }
    }
}
