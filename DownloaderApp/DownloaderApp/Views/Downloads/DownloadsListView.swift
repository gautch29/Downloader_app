//
//  DownloadsListView.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import SwiftUI

struct DownloadsListView: View {
    @StateObject private var viewModel = DownloadsViewModel()
    @StateObject private var pathsViewModel = PathsViewModel()
    @State private var showingAddDownload = false
    @Environment(\.scenePhase) var scenePhase
    @State private var selectedFilter: FilterOption = .all
    @State private var sheetInitialURL = ""
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case completed = "Completed"
    }
    
    var filteredDownloads: [Download] {
        switch selectedFilter {
        case .all:
            return viewModel.downloads
        case .active:
            return viewModel.activeDownloads
        case .completed:
            return viewModel.completedDownloads
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Clipboard banner removed

                
                Group {
                    if viewModel.isLoading && viewModel.downloads.isEmpty {
                        ProgressView("Loading downloads...")
                            .frame(maxHeight: .infinity)
                    } else if viewModel.downloads.isEmpty {
                        ContentUnavailableView(
                            "No Downloads",
                            systemImage: "arrow.down.circle",
                            description: Text("Add a 1fichier URL to start downloading")
                        )
                        .frame(maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(filteredDownloads) { download in
                                NavigationLink {
                                    DownloadDetailView(download: download, viewModel: viewModel)
                                } label: {
                                    DownloadRowView(download: download) {
                                        Task {
                                            await viewModel.cancelDownload(download)
                                        }
                                    }
                                }
                            }
                        }
                        .refreshable {
                            await viewModel.fetchDownloads()
                        }
                    }
                }
            }
            .navigationTitle("Downloads")
            .onAppear {
                viewModel.checkClipboard()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    viewModel.checkClipboard()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Filter", selection: $selectedFilter) {
                            ForEach(FilterOption.allCases, id: \.self) { option in
                                Label(option.rawValue, systemImage: iconForFilter(option))
                                    .tag(option)
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        sheetInitialURL = ""
                        showingAddDownload = true
                    } label: {
                        Label("Add Download", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddDownload) {
                AddDownloadView(
                    downloadsViewModel: viewModel,
                    pathsViewModel: pathsViewModel,
                    initialUrl: sheetInitialURL
                )
            }
            .task {
                await viewModel.fetchDownloads()
            }
            // Hidden button for keyboard shortcut removed
        }
        .alert("Link Detected", isPresented: Binding(
            get: { viewModel.clipboardURL != nil },
            set: { if !$0 { viewModel.clipboardURL = nil } }
        )) {
            Button("Download") {
                sheetInitialURL = viewModel.clipboardURL ?? ""
                showingAddDownload = true
            }
            Button("Cancel", role: .cancel) {
                viewModel.clipboardURL = nil
            }
        } message: {
            if let url = viewModel.clipboardURL {
                Text("Found 1fichier link:\n\(url)")
            }
        }
    }
    
    private func iconForFilter(_ filter: FilterOption) -> String {
        switch filter {
        case .all: return "square.stack.3d.up"
        case .active: return "arrow.down.circle"
        case .completed: return "checkmark.circle"
        }
    }
}

#Preview {
    DownloadsListView()
}
