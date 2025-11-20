//
//  DownloadRowView.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import SwiftUI

struct DownloadRowView: View {
    let download: Download
    let onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Filename and status
            HStack {
                Text(download.displayFilename)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                StatusBadge(status: download.status)
            }
            
            // Progress bar (if downloading)
            if download.status == .downloading || download.status == .pending {
                ProgressView(value: download.progressDecimal)
                    .tint(.blue)
                
                HStack {
                    Text("\(download.progressPercentage)%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if download.speed != nil {
                        Text(download.formattedSpeed)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Size and date
            HStack {
                Spacer()
                
                Text(download.addedAt.timeAgo())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if download.status == .downloading || download.status == .pending {
                Button(role: .destructive) {
                    onCancel()
                } label: {
                    Label("Cancel", systemImage: "xmark.circle")
                }
            }
        }
    }
}

struct StatusBadge: View {
    let status: DownloadStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundStyle(statusColor)
            .clipShape(Capsule())
    }
    
    private var statusColor: Color {
        switch status {
        case .pending: return .gray
        case .downloading: return .blue
        case .completed: return .green
        case .error: return .red
        case .cancelled: return .orange
        case .paused: return .yellow
        }
    }
}

#Preview {
    List {
        DownloadRowView(
            download: Download(
                id: "1",
                url: "https://1fichier.com/example",
                filename: "example_file.zip",
                status: .downloading,
                progress: 65,
                speed: "5 MB/s",
                targetPath: "/downloads",
                createdAt: Date(),
                updatedAt: Date()
            ),
            onCancel: {}
        )
        
        DownloadRowView(
            download: Download(
                id: "2",
                url: "https://1fichier.com/example2",
                filename: "completed_file.zip",
                status: .completed,
                progress: 100,
                speed: nil,
                targetPath: "/downloads",
                createdAt: Date().addingTimeInterval(-3600),
                updatedAt: Date()
            ),
            onCancel: {}
        )
    }
}
