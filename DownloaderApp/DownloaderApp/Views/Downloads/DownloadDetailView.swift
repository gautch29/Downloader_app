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
                        ProgressView(value: (download.progress ?? 0) / 100.0)
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
                
                if let errorMessage = download.errorMessage {
                    HStack {
                        Text("Error")
                        Spacer()
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            
            Section("Details") {
                DetailRow(label: "Filename", value: download.displayFilename)
                
                DetailRow(label: "Added", value: download.addedAt.formatted())
                
                if download.size != nil {
                    DetailRow(label: "Size", value: download.formattedSize)
                }
                
                if let targetPath = download.targetPath {
                    DetailRow(label: "Target Path", value: targetPath)
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
                id: 1,
                url: "https://1fichier.com/example",
                filename: "example_file.zip",
                status: .downloading,
                progress: 0.65,
                size: 1024 * 1024 * 100,
                speed: 1024 * 1024 * 5,
                addedAt: Date(),
                startedAt: Date(),
                completedAt: nil,
                errorMessage: nil
            ),
            viewModel: DownloadsViewModel()
        )
    }
}
