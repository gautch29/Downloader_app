//
//  Constants.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation

enum Constants {
    // API Configuration
    // Change this to your backend URL (e.g., "https://your-app.vercel.app")
    static let defaultBaseURL = "https://dl.flgr.fr"
    static var baseURL: String {
        UserDefaults.standard.string(forKey: "api_base_url") ?? defaultBaseURL
    }
    
    // API Endpoints
    enum Endpoints {
        static let login = "/api/auth/login"
        static let logout = "/api/auth/logout"
        static let session = "/api/auth/session"
        static let downloads = "/api/downloads"
        static let paths = "/api/paths"
        static let settings = "/api/settings"
        static let searchMovies = "/api/movies/search"
        static let movieLinks = "/api/movies/links"
        static let searchSeries = "/api/series/search"
        static let seriesLinks = "/api/series/links"
    }
    
    // Refresh Intervals
    static let downloadsRefreshInterval: TimeInterval = 2.0 // 2 seconds
    
    // Keychain Keys
    static let sessionCookieKey = "session_cookie"
}
