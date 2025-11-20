//
//  FileBrowserView.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import SwiftUI

struct FileBrowserView: View {
    let initialPath: String?
    @Binding var selectedPath: String?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = FileBrowserViewModel()
    
    @State private var showingCreateFolderAlert = false
    @State private var newFolderName = ""
    
    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let errorMessage = viewModel.errorMessage {
                ContentUnavailableView {
                    Label("Error", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Retry") {
                        Task {
                            await viewModel.loadPath(initialPath)
                        }
                    }
                }
            } else if viewModel.folders.isEmpty {
                ContentUnavailableView {
                    Label("Empty Folder", systemImage: "folder")
                } description: {
                    Text("No subfolders found in this directory.")
                }
            } else {
                ForEach(viewModel.folders) { folder in
                    NavigationLink(destination: FileBrowserView(initialPath: folder.path, selectedPath: $selectedPath)) {
                        Label(folder.name, systemImage: "folder")
                    }
                }
            }
        }
        .navigationTitle(initialPath == nil ? "Browse" : (initialPath as NSString?)?.lastPathComponent ?? "Browse")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingCreateFolderAlert = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                }
            }
            
            ToolbarItem(placement: .bottomBar) {
                if !viewModel.isLoading {
                    Button("Select This Folder") {
                        selectedPath = viewModel.currentPath
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .task {
            if viewModel.currentPath.isEmpty {
                await viewModel.loadPath(initialPath)
            }
        }
        .alert("New Folder", isPresented: $showingCreateFolderAlert) {
            TextField("Folder Name", text: $newFolderName)
            Button("Cancel", role: .cancel) {
                newFolderName = ""
            }
            Button("Create") {
                Task {
                    let success = await viewModel.createFolder(name: newFolderName)
                    if success {
                        newFolderName = ""
                    }
                }
            }
        } message: {
            Text("Create a new folder in \(viewModel.currentPath)")
        }
    }
}
