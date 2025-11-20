//
//  PathsView.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import SwiftUI

struct PathsView: View {
    @StateObject private var viewModel = PathsViewModel()
    @State private var showingAddPath = false
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.paths.isEmpty {
                    ProgressView("Loading paths...")
                } else if viewModel.paths.isEmpty {
                    ContentUnavailableView(
                        "No Paths",
                        systemImage: "folder",
                        description: Text("Add a download path to organize your files")
                    )
                } else {
                    List {
                        ForEach(viewModel.paths) { path in
                            PathRow(path: path, viewModel: viewModel)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let path = viewModel.paths[index]
                                Task {
                                    await viewModel.deletePath(path)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Paths")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddPath = true
                    } label: {
                        Label("Add Path", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPath) {
                AddPathView(viewModel: viewModel)
            }
            .task {
                await viewModel.fetchPaths()
            }
        }
    }
}

struct PathRow: View {
    let path: DownloadPath
    @ObservedObject var viewModel: PathsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(path.name)
                    .font(.headline)
                
                Spacer()
                
                if path.isDefault {
                    Text("Default")
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.2))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
            }
            
            Text(path.path)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            if !path.isDefault {
                Button {
                    Task {
                        await viewModel.setDefaultPath(path)
                    }
                } label: {
                    Label("Set Default", systemImage: "star.fill")
                }
                .tint(.blue)
            }
        }
    }
}

struct AddPathView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PathsViewModel
    
    @State private var name = ""
    @State private var path = ""
    @State private var isAdding = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .autocorrectionDisabled()
                } header: {
                    Text("Path Name")
                } footer: {
                    Text("A friendly name for this download path")
                }
                
                Section {
                    TextField("Path", text: $path)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                } header: {
                    Text("Server Path")
                } footer: {
                    Text("The absolute path on your server where files will be downloaded")
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Path")
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
                            let success = await viewModel.addPath(name: name, path: path)
                            isAdding = false
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(name.isEmpty || path.isEmpty || isAdding)
                }
            }
        }
    }
}

#Preview {
    PathsView()
}
