//
//  DownloadDetailView.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import SwiftUI

struct DownloadDetailView: View {
    let download: Download
    @ObservedObject var viewModel: DownloadsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Section("Status") {
                HStack {
                    Text("Status")
                    Spacer()
                    StatusBadge(status: download.status)
                }
                
                if download.status == .downloading || download.status == .pending {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Progress")
                            Spacer()
                            Text("\(download.progressPercentage)%")
                                .foregroundStyle(.secondary)
                        }
                        ProgressView(value: download.progress ?? 0)
                    }
                    
                    if let speed = download.speed {
                        HStack {
                            Text("Speed")
                            Spacer()
                            Text(download.formattedSpeed)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            Section("Details") {
                DetailRow(label: "Filename", value: download.displayFilename)
                
                if let size = download.size {
                    DetailRow(label: "Size", value: download.formattedSize)
                }
                
                DetailRow(label: "Added", value: download.addedAt.formatted())
                
                if let startedAt = download.startedAt {
                    DetailRow(label: "Started", value: startedAt.formatted())
                }
                
                if let completedAt = download.completedAt {
                    DetailRow(label: "Completed", value: completedAt.formatted())
                }
            }
            
            Section("URL") {
                Text(download.url)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if let errorMessage = download.errorMessage {
                Section("Error") {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            
            if download.status == .downloading || download.status == .pending {
                Section {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.cancelDownload(download)
                            dismiss()
                        }
                    } label: {
                        Label("Cancel Download", systemImage: "xmark.circle")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .navigationTitle("Download Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        DownloadDetailView(
            download: Download(
                id: 1,
                url: "https://1fichier.com/example",
                filename: "example_file.zip",
                status: .downloading,
                progress: 0.65,
                size: 1024 * 1024 * 150,
                speed: 1024 * 1024 * 5,
                addedAt: Date(),
                startedAt: Date(),
                completedAt: nil,
                errorMessage: nil,
                pathId: 1
            ),
            viewModel: DownloadsViewModel()
        )
    }
}
