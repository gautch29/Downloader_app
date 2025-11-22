//
//  SeriesDetailView.swift
//  DownloaderApp
//
//  Created on 2025-11-22.
//

import SwiftUI

struct SeriesDetailView: View {
    let series: Series
    @StateObject private var viewModel = SeriesViewModel()
    @State private var selectedQuality: SeriesQuality?
    @State private var episodes: [Episode] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack(alignment: .top, spacing: 16) {
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
                    .frame(width: 120, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(series.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(series.displayYear)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        if let inPlex = series.inPlex, inPlex {
                            Label("In Plex", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.green.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding()
                
                // Qualities
                if let qualities = series.qualities, !qualities.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Available Qualities")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(qualities) { quality in
                                    Button {
                                        Task {
                                            selectedQuality = quality
                                            if let fetchedEpisodes = await viewModel.getEpisodes(for: quality) {
                                                episodes = fetchedEpisodes
                                            }
                                        }
                                    } label: {
                                        VStack(alignment: .leading) {
                                            Text(quality.displayQuality)
                                                .font(.headline)
                                            Text(quality.displayLanguage)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding()
                                        .background(selectedQuality?.id == quality.id ? Color.accentColor : Color.gray.opacity(0.1))
                                        .foregroundStyle(selectedQuality?.id == quality.id ? .white : .primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Episodes
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if !episodes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Episodes")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(episodes) { episode in
                            Link(destination: URL(string: episode.url)!) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title2)
                                    
                                    Text(episode.displayTitle)
                                        .font(.body)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.right.square")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.bottom)
        }
        .navigationTitle("Series Details")
        .navigationBarTitleDisplayMode(.inline)
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
    }
}
