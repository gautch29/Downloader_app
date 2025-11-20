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

    
    @State private var safariURL: URL?

    
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
                                Task {
                                    if let link = await viewModel.getLinks(for: quality) {
                                        if let url = URL(string: link) {
                                            safariURL = url
                                        }
                                    }
                                }
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
        .sheet(item: $safariURL) { url in
            SafariView(url: url)
                .ignoresSafeArea()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
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
}

extension URL: Identifiable {
    public var id: String { absoluteString }
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
                
                Image(systemName: "safari")
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
