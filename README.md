# 1fichier Downloader iOS App

A modern iOS application for managing and monitoring downloads from 1fichier.com, built with SwiftUI and connected to a custom backend server.

## Features

### 📥 Download Management
- **Add Downloads**: Paste 1fichier URLs to queue downloads on your server
- **Real-time Progress**: Monitor download progress, speed, and status
- **Custom Filenames**: Optionally specify custom filenames for downloads
- **Clipboard Integration**: Quick-add downloads from clipboard with smart URL detection

### 📁 Path Management
- **Shortcuts**: Create and manage download path shortcuts
- **File Browser**: Browse server directories recursively
- **Folder Creation**: Create new folders directly from the app
- **Default Paths**: Set default download destinations

### 🎨 User Experience
- **Modern UI**: Clean, minimalist design with smooth animations
- **Dark Mode**: Full dark mode support
- **Password Manager Integration**: Keychain autofill for login
- **Real-time Updates**: Automatic refresh of download status

## Screenshots

*Coming soon*

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 6.0+
- Backend server (see [Backend Setup](#backend-setup))

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/Downloader_app.git
cd Downloader_app/DownloaderApp
```

2. Open the project in Xcode:
```bash
open DownloaderApp.xcodeproj
```

3. Update the API endpoint in `Constants.swift`:
```swift
static let baseURL = "http://your-server-address:3000"
```

4. Build and run the project (⌘R)

## Backend Setup

This app requires a backend server to handle downloads. The backend should implement the following API endpoints:

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout

### Downloads
- `GET /api/downloads` - List all downloads
- `POST /api/downloads` - Add new download
- `GET /api/downloads/:id` - Get download details
- `DELETE /api/downloads/:id` - Cancel download

### Paths
- `GET /api/paths` - List configured paths
- `POST /api/paths` - Add new path
- `DELETE /api/paths/:id` - Delete path
- `PUT /api/paths/:id/default` - Set default path
- `GET /api/paths/browse?path=` - Browse directory
- `POST /api/paths/create-folder` - Create new folder

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture:

```
DownloaderApp/
├── Models/           # Data models (Download, DownloadPath, etc.)
├── Views/            # SwiftUI views
│   ├── Auth/        # Login and authentication
│   ├── Downloads/   # Download management
│   └── Paths/       # Path management
├── ViewModels/      # Business logic and state management
├── Services/        # API clients and networking
└── Utilities/       # Helper functions and constants
```

## Key Technologies

- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for state management
- **URLSession**: Network requests
- **Keychain**: Secure credential storage

## Configuration

### API Endpoints
Update `Constants.swift` to configure your backend URL:
```swift
struct Constants {
    static let baseURL = "http://localhost:3000"
}
```

### Session Management
Sessions are persisted for 30 days by default. Adjust in `AuthViewModel.swift` if needed.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built with SwiftUI
- Designed for 1fichier.com integration
- Backend powered by Node.js/Express

## Support

For issues, questions, or suggestions, please open an issue on GitHub.
