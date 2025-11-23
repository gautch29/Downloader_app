#!/bin/bash

# Script to add Series files to Xcode project
# This uses the xcodeproj Ruby gem

cd /Users/gauthierbaron/Documents/Downloader_app/DownloaderApp

# Install xcodeproj gem if not already installed
if ! gem list xcodeproj -i > /dev/null 2>&1; then
    echo "Installing xcodeproj gem..."
    gem install xcodeproj
fi

# Create Ruby script to add files
cat > add_series_files.rb << 'EOF'
require 'xcodeproj'

project_path = 'DownloaderApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Files to add
files_to_add = [
  'DownloaderApp/Models/Series.swift',
  'DownloaderApp/Services/SeriesService.swift',
  'DownloaderApp/ViewModels/SeriesViewModel.swift',
  'DownloaderApp/Views/Series/SeriesSearchView.swift',
  'DownloaderApp/Views/Series/SeriesDetailView.swift'
]

# Get the main group
main_group = project.main_group

files_to_add.each do |file_path|
  # Check if file exists
  unless File.exist?(file_path)
    puts "Warning: #{file_path} does not exist"
    next
  end
  
  # Check if already in project
  if project.files.any? { |f| f.path == file_path }
    puts "#{file_path} already in project"
    next
  end
  
  # Add file reference
  file_ref = main_group.new_reference(file_path)
  
  # Add to target
  target.add_file_references([file_ref])
  
  puts "Added #{file_path}"
end

# Save the project
project.save

puts "Done!"
EOF

# Run the Ruby script
ruby add_series_files.rb

# Clean up
rm add_series_files.rb

echo "Files added to Xcode project. Please rebuild."
