//
//  SeriesSearchView.swift
//  DownloaderApp
//
//  Created on 2025-11-22.
//

import SwiftUI

struct SeriesSearchView: View {
    @StateObject private var viewModel = SeriesViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.series.isEmpty && viewModel.searchText.isEmpty {
                    ContentUnavailableView(
                        "Search Series",
                        systemImage: "tv",
                        description: Text("Search for series to download")
                    )
                } else if viewModel.series.isEmpty && !viewModel.searchText.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView.search(text: viewModel.searchText)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                            ForEach(viewModel.series) { series in
                                NavigationLink(destination: SeriesDetailView(series: series)) {
                                    SeriesGridItem(series: series)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Series")
            .searchable(text: $viewModel.searchText, prompt: "Search series...")
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
            .overlay(alignment: .bottom) {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding()
                        .background(.red.opacity(0.8))
                        .clipShape(Capsule())
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onTapGesture {
                            viewModel.errorMessage = nil
                        }
                }
            }
            .animation(.default, value: viewModel.errorMessage)
        }
    }
}

struct SeriesGridItem: View {
    let series: Series
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: series.posterURL) { phase in
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
                        .overlay(Image(systemName: "tv").font(.largeTitle))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 225)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 4)
            .overlay(alignment: .topTrailing) {
                if let inPlex = series.inPlex, inPlex {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.green)
                        .background(Circle().fill(.white))
                        .padding(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(series.title)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(series.displayYear)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 280)
    }
}

#Preview {
    SeriesSearchView()
}
