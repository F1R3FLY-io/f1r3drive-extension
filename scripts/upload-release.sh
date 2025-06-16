#!/bin/bash

set -e

# Configuration
REPO_OWNER="f1r3fly-io"
REPO_NAME="f1r3drive-extension"
BUILD_DIR="../build"
DMG_NAME="F1r3drive-Extensions"
DMG_FILE="$BUILD_DIR/$DMG_NAME.dmg"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if DMG file exists
if [[ ! -f "$DMG_FILE" ]]; then
    print_warning "DMG file not found: $DMG_FILE"
    print_status "Skipping upload - no DMG to upload"
    exit 0
fi

# Get version from user or use default
if [[ -z "$1" ]]; then
    print_warning "No version specified. Using default: v0.1.0"
    VERSION="v0.1.0"
else
    VERSION="$1"
fi

# Get release notes from user or use default
RELEASE_NOTES_FILE="../RELEASE_NOTES.md"
if [[ -f "$RELEASE_NOTES_FILE" ]]; then
    print_status "Using release notes from $RELEASE_NOTES_FILE"
    RELEASE_NOTES=$(cat "$RELEASE_NOTES_FILE")
else
    print_warning "No RELEASE_NOTES.md found, using default release notes"
    RELEASE_NOTES="## F1r3drive Extensions $VERSION

### Features
- Right-click context menu \"Change\" action for .token files in MacFUSE mounts
- Automatic folder unlocking for \"LOCKED-REMOTE-REV-\" prefixed folders
- Secure private key input interface
- Custom URL scheme support (f1r3drive://)

### Installation
1. Download and mount the DMG file
2. Drag RevFolderUnlockerApp to the Applications folder
3. Launch RevFolderUnlockerApp.app once to register the extension
4. Go to System Settings > Privacy & Security > Extensions > File Providers
5. Enable \"RevFolderUnlockerApp\"
6. Restart Finder (Cmd+Option+Esc → Finder → Relaunch)

### Requirements
- macOS 10.15 or later
- MacFUSE for mount detection
- Proper system permissions"
fi

print_status "Creating GitHub release $VERSION..."

# Create release using GitHub API
RELEASE_DATA=$(cat <<EOF
{
  "tag_name": "$VERSION",
  "target_commitish": "main",
  "name": "F1r3drive Extensions $VERSION",
  "body": $(echo "$RELEASE_NOTES" | jq -Rs .),
  "draft": false,
  "prerelease": false
}
EOF
)

# Create the release
RELEASE_RESPONSE=$(curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Content-Type: application/json" \
  -d "$RELEASE_DATA" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases")

# Check if release creation was successful
RELEASE_ID=$(echo "$RELEASE_RESPONSE" | jq -r '.id // empty')
if [[ -z "$RELEASE_ID" ]]; then
    print_error "Failed to create release"
    echo "Response: $RELEASE_RESPONSE"
    exit 1
fi

print_success "Release created with ID: $RELEASE_ID"

# Get upload URL
UPLOAD_URL=$(echo "$RELEASE_RESPONSE" | jq -r '.upload_url' | sed 's/{?name,label}//')

print_status "Uploading DMG file..."

# Get DMG file size for progress
DMG_SIZE=$(du -h "$DMG_FILE" | cut -f1)
print_status "Uploading $DMG_FILE ($DMG_SIZE)..."

# Upload the DMG file
UPLOAD_RESPONSE=$(curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @"$DMG_FILE" \
  "$UPLOAD_URL?name=$DMG_NAME.dmg&label=F1r3drive-Extensions-$VERSION.dmg")

# Check if upload was successful
ASSET_ID=$(echo "$UPLOAD_RESPONSE" | jq -r '.id // empty')
if [[ -z "$ASSET_ID" ]]; then
    print_error "Failed to upload DMG file"
    echo "Response: $UPLOAD_RESPONSE"
    exit 1
fi

print_success "DMG file uploaded successfully!"

# Get release URL
RELEASE_URL=$(echo "$RELEASE_RESPONSE" | jq -r '.html_url')
print_success "Release created successfully!"
print_status "Release URL: $RELEASE_URL"

# Get download URL for the asset
DOWNLOAD_URL=$(echo "$UPLOAD_RESPONSE" | jq -r '.browser_download_url')
print_status "Download URL: $DOWNLOAD_URL"

echo ""
print_success "🎉 Release $VERSION has been published!"
echo "📦 Asset: $DMG_NAME.dmg ($DMG_SIZE)"
echo "🔗 Release: $RELEASE_URL"
echo "⬇️  Download: $DOWNLOAD_URL" 