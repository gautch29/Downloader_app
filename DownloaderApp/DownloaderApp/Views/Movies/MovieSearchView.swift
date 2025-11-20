//
//  MovieSearchView.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import SwiftUI

struct MovieSearchView: View {
    @StateObject private var viewModel = MoviesViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.movies.isEmpty && viewModel.searchText.isEmpty {
                    ContentUnavailableView(
                        "Search Movies",
                        systemImage: "magnifyingglass",
                        description: Text("Search for movies to download")
                    )
                } else if viewModel.movies.isEmpty && !viewModel.searchText.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView.search(text: viewModel.searchText)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                            ForEach(viewModel.movies) { movie in
                                NavigationLink(destination: MovieDetailView(movie: movie)) {
                                    MovieGridItem(movie: movie)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Movies")
            .searchable(text: $viewModel.searchText, prompt: "Search movies...")
            .onChange(of: viewModel.searchText) { oldValue, newValue in
                viewModel.search(query: newValue)
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
    }
}

struct MovieGridItem: View {
    let movie: Movie
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: movie.posterURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(.gray.opacity(0.2))
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(.gray.opacity(0.2))
                        .overlay(Image(systemName: "film").font(.largeTitle))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 225)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(movie.displayYear)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 280)
    }
}

#Preview {
    MovieSearchView()
}
