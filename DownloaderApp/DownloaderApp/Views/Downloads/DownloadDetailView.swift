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
                        ProgressView(value: download.progressDecimal)
                    }
                    
                    if download.speed != nil {
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
                
                DetailRow(label: "Added", value: download.addedAt.formatted())
                
                if let targetPath = download.targetPath {
                    DetailRow(label: "Path", value: targetPath)
                }
            }
            
            Section("URL") {
                Text(download.url)
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
            viewModel: DownloadsViewModel()
        )
    }
}
