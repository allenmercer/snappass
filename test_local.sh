#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- 1. Cleaning up previous run (if any)..."
# Stop any running containers and remove the old 'echo_local' image
docker-compose -f docker-compose.local down --rmi local
# Remove the old source code directory
rm -rf source

echo "--- 2. Cloning official Snappass repository..."
git clone --depth 1 https://github.com/pinterest/snappass.git source

echo "--- 3. Applying Ailevate customizations..."
# Create a directory for images inside the cloned repo's static folder
mkdir -p source/snappass/static/img
mkdir -p source/snappass/static/css
mkdir -p source/snappass/static/scripts

# Copy the logo, stylesheet, HTML templates, and scripts
cp -Rv customizations/img/* source/snappass/static/img/
cat customizations/css/custom.css >> source/snappass/static/css/custom.css
cp -Rv customizations/templates/* source/snappass/templates/
cp -Rv source/snappass/static/snappass/scripts/* source/snappass/static/scripts

# Replace SnapPass in set_password
sed -i '' 's/SnapPass/Ailevate Secret Sharing Service/g' source/snappass/templates/set_password.html

# Replaces snappass in templates for script files
sed -i '' 's~/snappass~~' source/snappass/templates/*

# Replace all instances of the word snappass or snap pass, case insensitive, from any template to prevent leakage.
sed -i '' 's/snappass/Ailevate Secret Sharing Service/I' source/snappass/templates/*
sed -i '' 's/snap pass/Ailevate Secret Sharing Service/I' source/snappass/templates/*

echo "--- 4. Building and running containers with Docker Compose..."
# Build the new image and start the echo and redis containers in the background
docker-compose -f docker-compose.local up --build -d

echo ""
echo "✅ Success! Ailevate Echo is running."
echo "   View it in your browser at http://localhost:8080"
echo ""
echo "   Use 'docker logs -f snappass-echo-1' to see the application logs."
echo "   Use 'docker-compose -f docker-compose.local down' to stop the containers."
