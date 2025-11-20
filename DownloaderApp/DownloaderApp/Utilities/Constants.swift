//
//  Constants.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation

enum Constants {
    // API Configuration
    static let defaultBaseURL = "http://localhost:3000"
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
    }
    
    // Refresh Intervals
    static let downloadsRefreshInterval: TimeInterval = 2.0 // 2 seconds
    
    // Keychain Keys
    static let sessionCookieKey = "session_cookie"
}
