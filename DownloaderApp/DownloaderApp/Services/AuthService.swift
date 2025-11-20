//
//  AuthService.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let success: Bool
    let user: User?
    let message: String?
}

struct SessionResponse: Codable {
    let authenticated: Bool
    let user: User?
}

class AuthService {
    static let shared = AuthService()
    private let client = APIClient.shared
    
    private init() {}
    
    func login(username: String, password: String) async throws -> User {
        let request = LoginRequest(username: username, password: password)
        let response: LoginResponse = try await client.post(Constants.Endpoints.login, body: request)
        
        if response.success, let user = response.user {
            return user
        } else {
            throw APIError.serverError(response.message ?? "Login failed")
        }
    }
    
    func logout() async throws {
        struct EmptyResponse: Codable {}
        let _: EmptyResponse = try await client.post(Constants.Endpoints.logout, body: [:])
    }
    
    func checkSession() async throws -> User? {
        do {
            let response: SessionResponse = try await client.get(Constants.Endpoints.session)
            return response.authenticated ? response.user : nil
        } catch APIError.unauthorized {
            return nil
        }
    }
}
