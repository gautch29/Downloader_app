//
//  APIClient.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(String)
    case decodingError
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .serverError(let message):
            return message
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}

class APIClient {
    static let shared = APIClient()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = HTTPCookieStorage.shared
        config.httpCookieAcceptPolicy = .always
        config.httpShouldSetCookies = true
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Generic Request Methods
    
    func get<T: Decodable>(_ endpoint: String) async throws -> T {
        try await request(endpoint: endpoint, method: "GET")
    }
    
    func post<T: Decodable, U: Encodable>(_ endpoint: String, body: U) async throws -> T {
        try await request(endpoint: endpoint, method: "POST", body: body)
    }
    
    func post<T: Decodable>(_ endpoint: String, body: [String: Any]) async throws -> T {
        try await request(endpoint: endpoint, method: "POST", jsonBody: body)
    }
    
    func delete<T: Decodable>(_ endpoint: String) async throws -> T {
        try await request(endpoint: endpoint, method: "DELETE")
    }
    
    func put<T: Decodable, U: Encodable>(_ endpoint: String, body: U) async throws -> T {
        try await request(endpoint: endpoint, method: "PUT", body: body)
    }
    
    // MARK: - Private Request Handler
    
    private func request<T: Decodable, U: Encodable>(
        endpoint: String,
        method: String,
        body: U? = nil as String?
    ) async throws -> T {
        guard let url = URL(string: Constants.baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    print("Decoding error: \(error)")
                    print("Response data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    throw APIError.decodingError
                }
            case 401:
                throw APIError.unauthorized
            case 400...499:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Client error"
                throw APIError.serverError(errorMessage)
            case 500...599:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Server error"
                throw APIError.serverError(errorMessage)
            default:
                throw APIError.invalidResponse
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    private func request<T: Decodable>(
        endpoint: String,
        method: String,
        jsonBody: [String: Any]? = nil
    ) async throws -> T {
        guard let url = URL(string: Constants.baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let jsonBody = jsonBody {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    print("Decoding error: \(error)")
                    print("Response data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    throw APIError.decodingError
                }
            case 401:
                throw APIError.unauthorized
            case 400...499:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Client error"
                throw APIError.serverError(errorMessage)
            case 500...599:
                let errorMessage = String(data: data, encoding: .utf8) ?? "Server error"
                throw APIError.serverError(errorMessage)
            default:
                throw APIError.invalidResponse
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}
