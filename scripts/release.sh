#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if version is provided
if [[ -z "$1" ]]; then
    print_error "Version is required"
    echo "Usage: ./release.sh <version>"
    echo "Example: ./release.sh v1.0.0"
    exit 1
fi

VERSION="$1"

# Check if GitHub token is set
if [[ -z "$GITHUB_TOKEN" ]]; then
    print_error "GITHUB_TOKEN environment variable is not set"
    echo "Please set your GitHub token:"
    echo "export GITHUB_TOKEN=your_token_here"
    echo ""
    echo "You can create a token at: https://github.com/settings/tokens"
    echo "Required permissions: repo (Full control of private repositories)"
    exit 1
fi

print_status "🚀 Starting release process for version $VERSION"

# Step 1: Build the DMG
print_status "Step 1: Building DMG..."
if ! ./build.sh; then
    print_error "Build failed!"
    exit 1
fi

print_success "Build completed successfully!"

# Step 2: Upload to GitHub
print_status "Step 2: Uploading to GitHub..."
if ! ./upload-release.sh "$VERSION"; then
    print_error "Upload failed!"
    exit 1
fi

print_success "🎉 Release $VERSION completed successfully!"
print_status "Check your GitHub repository for the new release." 