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
    @State private var customFilename = ""
    @State private var selectedPathId: String?
    @State private var browserPath: String?
    @State private var isAdding = false
    
    @State private var showingFileBrowser = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("1fichier URL", text: $url)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                    
                    TextField("Custom Filename (Optional)", text: $customFilename)
                        .autocorrectionDisabled()
                } header: {
                    Text("Download URL")
                } footer: {
                    if !url.isEmpty && !url.is1FichierURL {
                        Text("Please enter a valid 1fichier.com URL")
                            .foregroundStyle(.red)
                    }
                }
                
                Section("Download Path") {
                    if let browserPath = browserPath {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Selected Path")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(browserPath)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                            
                            Spacer()
                            
                            Button {
                                self.browserPath = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.gray)
                            }
                            .buttonStyle(.borderless)
                        }
                    } else {
                        Picker("Shortcut", selection: $selectedPathId) {
                            Text("Default Path")
                                .tag(String?.none)
                            
                            ForEach(pathsViewModel.paths) { path in
                                Text(path.name)
                                    .tag(String?.some(path.id))
                            }
                        }
                    }
                    
                    Button {
                        showingFileBrowser = true
                    } label: {
                        Label(browserPath == nil ? "Browse Server..." : "Change Path...", systemImage: "folder")
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
                            // Determine target path
                            var targetPath: String? = nil
                            
                            if let browserPath = browserPath {
                                targetPath = browserPath
                            } else if let pathId = selectedPathId {
                                if let path = pathsViewModel.paths.first(where: { $0.id == pathId }) {
                                    targetPath = path.path
                                }
                            }
                            
                            await downloadsViewModel.addDownload(url: url, customFilename: customFilename.isEmpty ? nil : customFilename, targetPath: targetPath)
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
            .sheet(isPresented: $showingFileBrowser) {
                NavigationStack {
                    FileBrowserView(initialPath: nil, selectedPath: $browserPath)
                }
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
