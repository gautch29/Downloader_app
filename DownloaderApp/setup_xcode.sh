#!/bin/bash

# Create iOS App using xcodebuild
cd /Users/gauthierbaron/Documents/Downloader_app/DownloaderApp

# Remove the Package.swift since we want an iOS app, not a package
rm -f Package.swift

# Create a basic iOS app project structure
mkdir -p DownloaderApp.xcodeproj/project.xcworkspace/xcuserdata
mkdir -p DownloaderApp.xcodeproj/xcuserdata

# We'll use a template-based approach
echo "Creating Xcode project..."

# Generate the project using xcodegen if available, otherwise manual
if command -v xcodegen &> /dev/null; then
    echo "Using xcodegen..."
else
    echo "xcodegen not found. Please install it with: brew install xcodegen"
    echo "Or open Xcode and create a new iOS App project manually."
    exit 1
fi
