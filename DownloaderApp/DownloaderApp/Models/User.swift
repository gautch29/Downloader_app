//
//  User.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation

struct User: Codable, Identifiable {
    var id: String { username } // Use username as ID since backend doesn't return id
    let username: String
}
