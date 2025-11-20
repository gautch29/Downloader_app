# Setup Guide for iOS Downloader App

This guide will help you set up both the iOS app and the required backend API endpoints.

## Part 1: Backend Setup

### Step 1: Add API Route Handlers

Copy the API route handlers from `backend_api_examples/` to your Next.js backend repository:

```bash
# Navigate to your backend repository
cd /path/to/your/Downloader

# Copy the API routes
cp -r /Users/gauthierbaron/Documents/Downloader_app/backend_api_examples/auth app/api/
cp -r /Users/gauthierbaron/Documents/Downloader_app/backend_api_examples/downloads app/api/
cp -r /Users/gauthierbaron/Documents/Downloader_app/backend_api_examples/paths app/api/
cp -r /Users/gauthierbaron/Documents/Downloader_app/backend_api_examples/settings app/api/
cp /Users/gauthierbaron/Documents/Downloader_app/backend_api_examples/lib/auth.ts lib/
```

### Step 2: Verify Database Schema

Ensure your database schema includes all necessary fields. The API routes expect:

**downloads table:**
- `id`, `url`, `filename`, `status`, `progress`, `size`, `speed`
- `added_at`, `started_at`, `completed_at`, `error_message`, `path_id`

**paths table:**
- `id`, `name`, `path`, `default`

**settings table:**
- `id`, `key`, `value`

**users table:**
- `id`, `username`, `password_hash`

**sessions table:**
- `id`, `user_id`, `expires_at`

### Step 3: Test Backend API

Start your backend server:

```bash
npm run dev
```

Test the API endpoints:

```bash
# Test login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"your_username","password":"your_password"}'

# Test session (with cookie from login)
curl http://localhost:3000/api/auth/session \
  -H "Cookie: session_id=YOUR_SESSION_ID"

# Test downloads
curl http://localhost:3000/api/downloads \
  -H "Cookie: session_id=YOUR_SESSION_ID"
```

## Part 2: iOS App Setup

### Step 1: Create Xcode Project

1. Open Xcode
2. File → New → Project
3. Select "iOS" → "App"
4. Product Name: `DownloaderApp`
5. Interface: SwiftUI
6. Language: Swift
7. Save to: `/Users/gauthierbaron/Documents/Downloader_app/`

### Step 2: Add Source Files

1. In Xcode, right-click on the `DownloaderApp` folder
2. Select "Add Files to DownloaderApp..."
3. Navigate to `/Users/gauthierbaron/Documents/Downloader_app/DownloaderApp/DownloaderApp/`
4. Select all folders (Models, Services, ViewModels, Views, Utilities)
5. Make sure "Copy items if needed" is checked
6. Click "Add"

### Step 3: Replace App Entry Point

1. Delete the default `DownloaderAppApp.swift` file
2. The `DownloaderApp.swift` file you added will be the new entry point

### Step 4: Configure Backend URL

1. Open `Utilities/Constants.swift`
2. Update `defaultBaseURL` to your backend URL:
   - For local development: `http://localhost:3000`
   - For production: `https://your-backend-url.com`

### Step 5: Configure App Transport Security (for HTTP)

If using HTTP (localhost), add to `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

**Note:** For production, always use HTTPS.

### Step 6: Build and Run

1. Select a simulator or device
2. Press `Cmd+R` to build and run
3. The app should launch and show the login screen

## Part 3: Testing the App

### Test Authentication

1. Launch the app
2. Enter your backend username and password
3. Tap "Login"
4. You should be redirected to the Downloads tab

### Test Adding Downloads

1. Tap the "+" button in the Downloads tab
2. Enter a 1fichier URL (e.g., `https://1fichier.com/?abc123`)
3. Select a path (optional)
4. Tap "Add"
5. The download should appear in the list

### Test Path Management

1. Navigate to the Paths tab
2. Tap "+" to add a new path
3. Enter a name (e.g., "Movies") and server path (e.g., "/downloads/movies")
4. Tap "Add"
5. Swipe right on a path to set it as default
6. Swipe left to delete

### Test Settings

1. Navigate to the Settings tab
2. Enter your 1fichier API key
3. Configure Plex settings (optional)
4. Tap "Save Settings"
5. Verify the success message appears

## Troubleshooting

### "Cannot connect to server"

**Problem:** The app can't reach the backend.

**Solutions:**
1. Verify the backend is running (`npm run dev`)
2. Check the URL in `Constants.swift`
3. For iOS Simulator with localhost, use `http://localhost:3000`
4. For physical device, use your computer's IP address (e.g., `http://192.168.1.100:3000`)
5. Ensure App Transport Security is configured for HTTP

### "Unauthorized" errors

**Problem:** Session authentication is failing.

**Solutions:**
1. Check that cookies are being set correctly in the backend
2. Verify the session hasn't expired
3. Try logging out and logging back in
4. Check backend logs for authentication errors

### Downloads not updating

**Problem:** Progress isn't showing in real-time.

**Solutions:**
1. Verify the backend worker is running
2. Check that the downloads table is being updated
3. Ensure auto-refresh is working (check `DownloadsViewModel`)
4. Pull down to manually refresh the list

### Build errors in Xcode

**Problem:** The project won't build.

**Solutions:**
1. Ensure all files are added to the target
2. Check for missing imports
3. Clean build folder: Product → Clean Build Folder
4. Restart Xcode

## Next Steps

1. **Customize the UI**: Modify colors, fonts, and layouts in the Views
2. **Add Features**: Implement additional functionality like download history
3. **Optimize Performance**: Add caching and background refresh
4. **Add Tests**: Write unit tests for ViewModels and Services
5. **Deploy**: Build for TestFlight or App Store

## Support

For issues or questions:
- Check the API documentation: `API_DOCUMENTATION.md`
- Review the iOS app README: `DownloaderApp/README.md`
- Check backend logs for API errors
- Use Xcode debugger for iOS issues

## File Structure Reference

```
Downloader_app/
├── API_DOCUMENTATION.md          # API endpoint specifications
├── SETUP_GUIDE.md               # This file
├── backend_api_examples/        # Backend API route handlers
│   ├── auth/
│   ├── downloads/
│   ├── paths/
│   ├── settings/
│   └── lib/
└── DownloaderApp/               # iOS app
    ├── README.md
    └── DownloaderApp/
        ├── Models/
        ├── Services/
        ├── ViewModels/
        ├── Views/
        ├── Utilities/
        └── DownloaderApp.swift
```
