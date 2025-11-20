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
                            .tag(nil as Int?)
                        
                        ForEach(pathsViewModel.paths) { path in
                            Text(path.name)
                                .tag(path.id as Int?)
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
                    Button("Add") {
                        Task {
                            isAdding = true
                            let success = await downloadsViewModel.addDownload(url: url, pathId: selectedPathId)
                            isAdding = false
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!url.is1FichierURL || isAdding)
                }
            }
            .task {
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
