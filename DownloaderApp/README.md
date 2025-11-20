# iOS Downloader App

A native iOS application built with SwiftUI that interfaces with the Downloader backend for managing 1fichier downloads.

## Features

- 🔐 **Authentication** - Secure login with session management
- ⬇️ **Download Management** - Add, monitor, and cancel downloads
- 📊 **Real-time Progress** - Live progress updates with speed and size information
- 📁 **Path Management** - Organize downloads into different server paths
- ⚙️ **Settings** - Configure 1fichier API key and Plex integration
- 🎨 **Modern UI** - Clean SwiftUI interface with dark mode support

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Backend server running (see backend setup below)

## Project Structure

```
DownloaderApp/
├── Models/              # Data models
│   ├── User.swift
│   ├── Download.swift
│   ├── DownloadPath.swift
│   ├── Settings.swift
│   └── DownloadStatus.swift
├── Services/            # Networking layer
│   ├── APIClient.swift
│   ├── AuthService.swift
│   ├── DownloadService.swift
│   ├── PathService.swift
│   └── SettingsService.swift
├── ViewModels/          # State management
│   ├── AuthViewModel.swift
│   ├── DownloadsViewModel.swift
│   ├── PathsViewModel.swift
│   └── SettingsViewModel.swift
├── Views/               # SwiftUI views
│   ├── Auth/
│   │   └── LoginView.swift
│   ├── Downloads/
│   │   ├── DownloadsListView.swift
│   │   ├── DownloadRowView.swift
│   │   ├── AddDownloadView.swift
│   │   └── DownloadDetailView.swift
│   ├── Paths/
│   │   └── PathsView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── MainTabView.swift
├── Utilities/           # Helper utilities
│   ├── Constants.swift
│   └── Extensions.swift
└── DownloaderApp.swift  # App entry point
```

## Setup

### 1. Backend Setup

The iOS app requires REST API endpoints on your backend. See `API_DOCUMENTATION.md` for the required endpoints.

You'll need to add the following API routes to your Next.js backend:
- `/api/auth/*` - Authentication endpoints
- `/api/downloads` - Download management
- `/api/paths` - Path management
- `/api/settings` - Settings management

### 2. Configure Backend URL

By default, the app connects to `http://localhost:3000`. To change this:

1. Open `Constants.swift`
2. Update `defaultBaseURL` to your backend URL
3. Or set it at runtime via UserDefaults: `UserDefaults.standard.set("https://your-server.com", forKey: "api_base_url")`

### 3. Build and Run

1. Open the project in Xcode
2. Select your target device or simulator
3. Press `Cmd+R` to build and run

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** pattern:

- **Models**: Codable structs representing data from the API
- **Services**: Handle all network requests using async/await
- **ViewModels**: Manage state and business logic using `@ObservableObject`
- **Views**: SwiftUI views that observe ViewModels

### Key Features

#### Auto-Refresh
Downloads are automatically refreshed every 2 seconds to show real-time progress updates.

#### Session Management
User sessions are maintained via HTTP cookies, automatically handled by `URLSession`.

#### Error Handling
Comprehensive error handling with user-friendly error messages throughout the app.

## Usage

### Login
1. Launch the app
2. Enter your username and password
3. Tap "Login"

### Add Download
1. Navigate to the Downloads tab
2. Tap the "+" button
3. Enter a 1fichier URL
4. Select a download path (optional)
5. Tap "Add"

### Manage Paths
1. Navigate to the Paths tab
2. Tap "+" to add a new path
3. Swipe left on a path to delete
4. Swipe right to set as default

### Configure Settings
1. Navigate to the Settings tab
2. Enter your 1fichier API key
3. Configure Plex integration (optional)
4. Tap "Save Settings"

## API Integration

The app communicates with the backend using REST APIs. All requests include:
- JSON content type
- Session cookies for authentication
- ISO 8601 date formatting

See `API_DOCUMENTATION.md` for complete API specifications.

## Development

### Adding New Features

1. **Model**: Create/update models in `Models/`
2. **Service**: Add API methods in appropriate service
3. **ViewModel**: Create/update ViewModel for state management
4. **View**: Build SwiftUI view using the ViewModel

### Testing

The app includes SwiftUI previews for all views. Use Xcode's preview canvas for rapid UI development.

## Troubleshooting

### Cannot Connect to Server
- Verify the backend URL in `Constants.swift`
- Ensure the backend is running
- Check network connectivity

### Session Expired
- The app will automatically redirect to login
- Re-authenticate to continue

### Downloads Not Updating
- Check that auto-refresh is enabled
- Verify backend worker is running
- Check network connection

## License

This project is part of the Downloader application suite.
