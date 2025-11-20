# Backend API Endpoints Documentation

This document describes the REST API endpoints that need to be added to the Next.js backend to support the iOS app.

## Authentication Endpoints

### POST /api/auth/login
Login with username and password.

**Request Body:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": 1,
    "username": "string"
  }
}
```

### POST /api/auth/logout
Logout current user.

**Response:**
```json
{
  "success": true
}
```

### GET /api/auth/session
Check current session status.

**Response:**
```json
{
  "authenticated": true,
  "user": {
    "id": 1,
    "username": "string"
  }
}
```

## Downloads Endpoints

### GET /api/downloads
Get all downloads for the current user.

**Response:**
```json
{
  "downloads": [
    {
      "id": 1,
      "url": "string",
      "filename": "string",
      "status": "downloading",
      "progress": 0.65,
      "size": 157286400,
      "speed": 5242880,
      "added_at": "2025-11-20T12:00:00Z",
      "started_at": "2025-11-20T12:01:00Z",
      "completed_at": null,
      "error_message": null,
      "path_id": 1
    }
  ]
}
```

### POST /api/downloads
Add a new download.

**Request Body:**
```json
{
  "url": "string",
  "path_id": 1  // optional
}
```

**Response:**
```json
{
  "success": true,
  "download": {
    "id": 1,
    "url": "string",
    "filename": null,
    "status": "pending",
    "progress": null,
    "size": null,
    "speed": null,
    "added_at": "2025-11-20T12:00:00Z",
    "started_at": null,
    "completed_at": null,
    "error_message": null,
    "path_id": 1
  }
}
```

### DELETE /api/downloads/[id]
Cancel a download.

**Response:**
```json
{
  "success": true,
  "message": "Download cancelled"
}
```

### GET /api/downloads/[id]
Get details of a specific download.

**Response:**
```json
{
  "id": 1,
  "url": "string",
  "filename": "string",
  "status": "downloading",
  "progress": 0.65,
  "size": 157286400,
  "speed": 5242880,
  "added_at": "2025-11-20T12:00:00Z",
  "started_at": "2025-11-20T12:01:00Z",
  "completed_at": null,
  "error_message": null,
  "path_id": 1
}
```

## Paths Endpoints

### GET /api/paths
Get all download paths.

**Response:**
```json
{
  "paths": [
    {
      "id": 1,
      "name": "Movies",
      "path": "/downloads/movies",
      "default": true
    }
  ]
}
```

### POST /api/paths
Add a new path.

**Request Body:**
```json
{
  "name": "string",
  "path": "string"
}
```

**Response:**
```json
{
  "success": true,
  "path": {
    "id": 1,
    "name": "string",
    "path": "string",
    "default": false
  }
}
```

### PUT /api/paths/[id]/default
Set a path as default.

**Response:**
```json
{
  "success": true,
  "message": "Path set as default"
}
```

### DELETE /api/paths/[id]
Delete a path.

**Response:**
```json
{
  "success": true,
  "message": "Path deleted"
}
```

## Settings Endpoints

### GET /api/settings
Get current settings.

**Response:**
```json
{
  "settings": {
    "1fichier_api_key": "string",
    "plex_url": "string",
    "plex_token": "string"
  }
}
```

### PUT /api/settings
Update settings.

**Request Body:**
```json
{
  "1fichier_api_key": "string",
  "plex_url": "string",
  "plex_token": "string"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Settings updated"
}
```

## Implementation Notes

- All endpoints require authentication (except `/api/auth/login`)
- Use session cookies for authentication
- Dates should be in ISO 8601 format
- File sizes are in bytes
- Progress is a decimal between 0 and 1
- Speed is in bytes per second
