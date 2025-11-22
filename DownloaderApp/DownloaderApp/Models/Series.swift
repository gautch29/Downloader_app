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
    
    var displayQuality: String {
        quality.isEmpty ? "Unknown" : quality
    }
    
    var displayLanguage: String {
        language.isEmpty ? "Unknown" : language
    }
}

struct Episode: Codable, Identifiable {
    var id: String { url }
    let title: String
    let url: String
    let episodeNumber: String?
    let seasonNumber: String?
    
    var displayTitle: String {
        if let s = seasonNumber, let e = episodeNumber {
            return "S\(s)E\(e) - \(title)"
        }
        return title
    }
}

struct SeriesSearchResponse: Codable {
    let series: [Series]
    let total: Int?
}

struct SeriesLinksRequest: Codable {
    let url: String
}

struct SeriesLinksResponse: Codable {
    let episodes: [Episode]
}
