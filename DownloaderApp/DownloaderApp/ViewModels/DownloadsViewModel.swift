//
//  DownloadsViewModel.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation
import SwiftUI

@MainActor
class DownloadsViewModel: ObservableObject {
    @Published var downloads: [Download] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var filterStatus: DownloadStatus?
    
    private let downloadService = DownloadService.shared
    private var refreshTimer: Timer?
    
    var filteredDownloads: [Download] {
        if let status = filterStatus {
            return downloads.filter { $0.status == status }
        }
        return downloads
    }
    
    var activeDownloads: [Download] {
        downloads.filter { $0.status == .downloading || $0.status == .pending }
    }
    
    var completedDownloads: [Download] {
        downloads.filter { $0.status == .completed }
    }
    
    init() {
        startAutoRefresh()
    }
    
    deinit {
        stopAutoRefresh()
    }
    
    func fetchDownloads() async {
        isLoading = true
        errorMessage = nil
        
        do {
            downloads = try await downloadService.getDownloads()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func addDownload(url: String, pathId: Int? = nil) async -> Bool {
        errorMessage = nil
        
        do {
            let newDownload = try await downloadService.addDownload(url: url, pathId: pathId)
            downloads.insert(newDownload, at: 0)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func cancelDownload(_ download: Download) async {
        errorMessage = nil
        
        do {
            try await downloadService.cancelDownload(id: download.id)
            if let index = downloads.firstIndex(where: { $0.id == download.id }) {
                downloads[index] = Download(
                    id: download.id,
                    url: download.url,
                    filename: download.filename,
                    status: .cancelled,
                    progress: download.progress,
                    size: download.size,
                    speed: nil,
                    addedAt: download.addedAt,
                    startedAt: download.startedAt,
                    completedAt: nil,
                    errorMessage: nil,
                    pathId: download.pathId
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func startAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: Constants.downloadsRefreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.refreshDownloadsInBackground()
            }
        }
    }
    
    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    private func refreshDownloadsInBackground() async {
        do {
            downloads = try await downloadService.getDownloads()
        } catch {
            // Silently fail for background refreshes
        }
    }
}
