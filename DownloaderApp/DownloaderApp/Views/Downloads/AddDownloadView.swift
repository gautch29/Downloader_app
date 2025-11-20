//
//  AddDownloadView.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import SwiftUI

struct AddDownloadView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var downloadsViewModel: DownloadsViewModel
    @ObservedObject var pathsViewModel: PathsViewModel
    
    var initialUrl: String = ""
    
    @State private var url = ""
    @State private var selectedPathId: Int?
    @State private var isAdding = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("1fichier URL", text: $url)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                } header: {
                    Text("Download URL")
                } footer: {
                    if !url.isEmpty && !url.is1FichierURL {
                        Text("Please enter a valid 1fichier.com URL")
                            .foregroundStyle(.red)
                    }
                }
                
                Section("Download Path") {
                    Picker("Path", selection: $selectedPathId) {
                        Text("Default Path")
                            .tag(String?.none)
                        
                        ForEach(pathsViewModel.paths) { path in
                            Text(path.name)
                                .tag(String?.some(path.id))
                        }
                    }
                }
                
                if let errorMessage = downloadsViewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Download")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add Download") {
                        isAdding = true
                        Task {
                            // Find the selected path string
                            var targetPath: String? = nil
                            if let pathId = selectedPathId {
                                if let path = pathsViewModel.paths.first(where: { $0.id == pathId }) {
                                    targetPath = path.path
                                }
                            }
                            
                            await downloadsViewModel.addDownload(url: url, targetPath: targetPath)
                            isAdding = false
                            dismiss()
                        }
                    }
                    .disabled(!url.is1FichierURL || isAdding)
                }
            }
            .task {
                if !initialUrl.isEmpty {
                    url = initialUrl
                }
                await pathsViewModel.fetchPaths()
            }
        }
    }
}

#Preview {
    AddDownloadView(
        downloadsViewModel: DownloadsViewModel(),
        pathsViewModel: PathsViewModel()
    )
}
