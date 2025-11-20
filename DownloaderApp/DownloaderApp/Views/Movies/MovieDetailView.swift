//
//  MovieDetailView.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @StateObject private var viewModel = MoviesViewModel()
    @StateObject private var pathsViewModel = PathsViewModel() // To get paths for download
    
    @State private var selectedQuality: MovieQuality?
    @State private var showingDownloadConfirmation = false
    @State private var selectedPathId: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with Poster and Info
                HStack(alignment: .top, spacing: 16) {
                    AsyncImage(url: movie.posterURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(.gray.opacity(0.2))
                            .overlay(Image(systemName: "film"))
                    }
                    .frame(width: 120, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(movie.title)
                            .font(.title2.bold())
                        
                        Text(movie.displayYear)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        if let inPlex = movie.inPlex, inPlex {
                            Label("In Plex", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(.green.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding()
                
                // Qualities List
                if let qualities = movie.qualities, !qualities.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Available Qualities")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(qualities) { quality in
                            QualityRow(quality: quality) {
                                selectedQuality = quality
                                showingDownloadConfirmation = true
                            }
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "No Links Found",
                        systemImage: "link.badge.plus",
                        description: Text("No download links available for this movie")
                    )
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingDownloadConfirmation) {
            NavigationStack {
                Form {
                    Section {
                        Text("Download \(movie.title)?")
                            .font(.headline)
                        
                        if let quality = selectedQuality {
                            LabeledContent("Quality", value: quality.displayQuality)
                            LabeledContent("Language", value: quality.displayLanguage)
                            if let size = quality.fileSize {
                                LabeledContent("Size", value: size)
                            }
                        }
                    }
                    
                    Section("Download Path") {
                        Picker("Path", selection: $selectedPathId) {
                            Text("Default Path")
                                .tag(nil as String?)
                            
                            ForEach(pathsViewModel.paths) { path in
                                Text(path.name)
                                    .tag(path.id as String?)
                            }
                        }
                    }
                }
                .navigationTitle("Confirm Download")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingDownloadConfirmation = false
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Download") {
                            startDownload()
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
                .overlay {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .task {
            await pathsViewModel.fetchPaths()
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func startDownload() {
        guard let quality = selectedQuality else { return }
        
        Task {
            let success = await viewModel.getLinksAndDownload(
                quality: quality,
                targetPath: selectedPathId
            )
            
            if success {
                showingDownloadConfirmation = false
            }
        }
    }
}

struct QualityRow: View {
    let quality: MovieQuality
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(quality.displayQuality)
                        .font(.headline)
                    Text(quality.displayLanguage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if let size = quality.fileSize {
                    Text(size)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Image(systemName: "arrow.down.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(movie: Movie(
            id: "1",
            title: "Inception",
            cleanTitle: "Inception",
            year: "2010",
            poster: "https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg",
            inPlex: false,
            qualities: [
                MovieQuality(
                    quality: "1080p",
                    language: "FRENCH",
                    url: "http://example.com",
                    fileSize: "2.5 GB",
                    links: []
                ),
                MovieQuality(
                    quality: "720p",
                    language: "MULTI",
                    url: "http://example.com",
                    fileSize: "1.2 GB",
                    links: []
                )
            ]
        ))
    }
}
