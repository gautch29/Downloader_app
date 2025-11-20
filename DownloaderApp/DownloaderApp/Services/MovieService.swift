//
//  MovieService.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation

class MovieService {
    static let shared = MovieService()
    private let client = APIClient.shared
    
    private init() {}
    
    func searchMovies(query: String) async throws -> [Movie] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw APIError.invalidURL
        }
        
        let endpoint = "\(Constants.Endpoints.searchMovies)?q=\(encodedQuery)"
        let response: MovieSearchResponse = try await client.get(endpoint)
        return response.movies
    }
    
    func getMovieLinks(url: String) async throws -> [String] {
        let request = MovieLinksRequest(url: url)
        let response: MovieLinksResponse = try await client.post(Constants.Endpoints.movieLinks, body: request)
        return response.links
    }
}
