//
//  SeriesService.swift
//  DownloaderApp
//
//  Created on 2025-11-22.
//

import Foundation

class SeriesService {
    static let shared = SeriesService()
    private let client = APIClient.shared
    
    private init() {}
    
    func searchSeries(query: String) async throws -> [Series] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw APIError.invalidURL
        }
        
        let endpoint = "\(Constants.Endpoints.searchSeries)?q=\(encodedQuery)"
        let response: SeriesSearchResponse = try await client.get(endpoint)
        return response.series
    }
    
    func getSeriesEpisodes(url: String) async throws -> [Episode] {
        let request = SeriesLinksRequest(url: url)
        let response: SeriesLinksResponse = try await client.post(Constants.Endpoints.seriesLinks, body: request)
        return response.episodes
    }
}
