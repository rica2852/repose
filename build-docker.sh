#!/bin/bash
# Build script for Repose Docker image with Java 11
# This script builds the Repose packages and Docker image

set -e  # Exit on error

echo "========================================="
echo "Building Repose with Java 11"
echo "========================================="

# Check if Java 11+ is available
JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
if [ "$JAVA_VERSION" -lt 11 ]; then
    echo "ERROR: Java 11 or later is required. Current version: $JAVA_VERSION"
    echo "Please install Java 11+ and set JAVA_HOME appropriately."
    exit 1
fi

echo "✓ Java version check passed (Java $JAVA_VERSION)"
echo ""

# Step 1: Clean and build packages
echo "Step 1: Building Repose packages..."
./gradlew clean buildAll

if [ $? -ne 0 ]; then
    echo "ERROR: Gradle build failed"
    exit 1
fi

echo "✓ Packages built successfully"
echo ""

# Step 2: Build Docker image
echo "Step 2: Building Docker image..."
docker build -f Dockerfile-new -t repose:9.1.0.5-java11-patched .

if [ $? -ne 0 ]; then
    echo "ERROR: Docker build failed"
    exit 1
fi

echo "✓ Docker image built successfully"
echo ""

# Step 3: Verify
echo "Step 3: Verifying image..."
docker images | grep repose

echo ""
echo "========================================="
echo "Build completed successfully!"
echo "========================================="
echo ""
echo "To run the container:"
echo "  docker-compose up -d"
echo ""
echo "Or:"
echo "  docker run -d -p 8080:8080 --name repose repose:9.1.0.5-java11-patched"
echo ""
echo "To verify Java version:"
echo "  docker run --rm repose:9.1.0.5-java11-patched java -version"
