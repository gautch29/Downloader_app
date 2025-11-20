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
            ZStack(alignment: .top) {
                Group {
                    if viewModel.isLoading && viewModel.downloads.isEmpty {
                        ProgressView("Loading downloads...")
                    } else if viewModel.downloads.isEmpty {
                        ContentUnavailableView(
                            "No Downloads",
                            systemImage: "arrow.down.circle",
                            description: Text("Add a 1fichier URL to start downloading")
                        )
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
                
                if let clipboardURL = viewModel.clipboardURL {
                    VStack {
                        HStack {
                            Image(systemName: "doc.on.clipboard")
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading) {
                                Text("Link found in clipboard")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(clipboardURL)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Button("Add") {
                                showingAddDownload = true
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 2)
                    }
                    .padding()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
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
                    initialUrl: viewModel.clipboardURL ?? ""
                )
            }
            .task {
                await viewModel.fetchDownloads()
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
