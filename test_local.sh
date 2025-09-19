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

# Copy the logo, stylesheet, and all HTML templates
cp -Rv customizations/img/* source/snappass/static/img/
cat customizations/css/custom.css >> source/snappass/static/snappass/css/custom.css
cp -Rv customizations/templates/* source/snappass/templates/

# Replace SnapPass in set_password
sed -i '' 's/SnapPass/Ailevate Echo/g' source/snappass/templates/set_password.html

echo "--- 4. Building and running containers with Docker Compose..."
# Build the new image and start the echo and redis containers in the background
docker-compose -f docker-compose.local up --build -d

echo ""
echo "✅ Success! Ailevate Echo is running."
echo "   View it in your browser at http://localhost:8080"
echo ""
echo "   Use 'docker-compose logs -f echo' to see the application logs."
echo "   Use 'docker-compose down' to stop the containers."
