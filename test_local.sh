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

# Copy the logo, stylesheet, and all HTML templates
cp -Rv customizations/img/* source/snappass/static/img/
cat customizations/css/custom.css >> source/snappass/static/css/custom.css
cp -Rv customizations/templates/* source/snappass/templates/

# Replace SnapPass in set_password
sed -i '' 's/SnapPass/Ailevate Echo/g' source/snappass/templates/set_password.html

# Replace all instances of the word snappass or snap pass, case insensitive, from any template to prevent leakage.
sed -i '' '/STATIC_URL/! s/snappass/ailevateecho/I' source/snappass/templates/*
sed -i '' '/STATIC_URL/! s/snap pass/ailevate echo/I' source/snappass/templates/*

echo "--- 4. Building and running containers with Docker Compose..."
# Build the new image and start the echo and redis containers in the background
docker-compose -f docker-compose.local up --build -d

echo ""
echo "✅ Success! Ailevate Echo is running."
echo "   View it in your browser at http://localhost:8080"
echo ""
echo "   Use 'docker logs -f snappass-echo-1' to see the application logs."
echo "   Use 'docker-compose -f docker-compose.local down' to stop the containers."
