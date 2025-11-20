//
//  MainTabView.swift
//  DownloaderApp
//
//  Created on 2025-11-20.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            DownloadsListView()
                .tabItem {
                    Label("Downloads", systemImage: "arrow.down.circle")
                }
            
            PathsView()
                .tabItem {
                    Label("Paths", systemImage: "folder")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
