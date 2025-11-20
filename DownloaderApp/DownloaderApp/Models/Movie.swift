//
//  Movie.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation

struct Movie: Codable, Identifiable {
    let id: String
    let title: String
    let cleanTitle: String?
    let year: String?
    let poster: String?
    let inPlex: Bool?
    let qualities: [MovieQuality]?
    
    var displayYear: String {
        year ?? "Unknown Year"
    }
    
    var posterURL: URL? {
        guard let poster = poster, !poster.isEmpty else { return nil }
        return URL(string: poster)
    }
}

struct MovieQuality: Codable, Identifiable {
    var id: String { url } // Use URL as ID since it's unique per quality option
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

struct MovieSearchResponse: Codable {
    let movies: [Movie]
    let total: Int?
}

struct MovieLinksRequest: Codable {
    let url: String
}

struct MovieLinksResponse: Codable {
    let links: [String]
}
