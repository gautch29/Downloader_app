//
//  Series.swift
//  DownloaderApp
//
//  Created on 2025-11-22.
//

import Foundation

struct Series: Codable, Identifiable {
    let id: String
    let title: String
    let cleanTitle: String?
    let year: String?
    let poster: String?
    let inPlex: Bool?
    let qualities: [SeriesQuality]?
    
    var displayYear: String {
        year ?? "Unknown Year"
    }
    
    var posterURL: URL? {
        guard let poster = poster, !poster.isEmpty else { return nil }
        return URL(string: poster)
    }
}

struct SeriesQuality: Codable, Identifiable {
    var id: String { url }
    let quality: String
    let language: String
    let url: String
    let fileSize: String?
    let links: [String]?
    
    var displayQuality: String {
        quality.isEmpty ? "Unknown" : quality
    }
    
    var displayLanguage: String {
        language.isEmpty ? "Unknown" : language
    }
}

struct Episode: Codable, Identifiable {
    let episode: String
    let link: String
    
    var id: String { link }
    
    var displayTitle: String {
        episode
    }
    
    var url: String {
        link
    }
}

struct SeriesSearchResponse: Codable {
    let movies: [Series]  // API returns "movies" key for series too
    let total: Int?
    
    // Map to series for easier access
    var series: [Series] {
        movies
    }
}

struct SeriesLinksRequest: Codable {
    let url: String
}

struct SeriesLinksResponse: Codable {
    let episodes: [Episode]
}
