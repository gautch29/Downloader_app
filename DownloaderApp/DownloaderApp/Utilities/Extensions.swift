//
//  Extensions.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import Foundation

extension Date {
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

extension Int64 {
    func formatBytes() -> String {
        ByteCountFormatter.string(fromByteCount: self, countStyle: .file)
    }
}

extension String {
    var isValidURL: Bool {
        guard let url = URL(string: self) else { return false }
        return url.scheme != nil && url.host != nil
    }
    
    var is1FichierURL: Bool {
        self.contains("1fichier.com")
    }
}
