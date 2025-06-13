#!/bin/bash

set -e

PROJECT_NAME="F1r3driveExtensions"
SCHEME_MAIN="RevFolderUnlockerApp"
BUILD_DIR="build"
DMG_NAME="F1r3drive-Extensions"

echo "🧹 Cleaning previous builds..."
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

echo "📦 Building F1r3drive Extensions App (includes FinderSync Extension)..."
xcodebuild archive \
  -project $PROJECT_NAME.xcodeproj \
  -scheme $SCHEME_MAIN \
  -archivePath $BUILD_DIR/$SCHEME_MAIN.xcarchive \
  -configuration Release \
  -quiet

xcodebuild -exportArchive \
  -archivePath $BUILD_DIR/$SCHEME_MAIN.xcarchive \
  -exportPath $BUILD_DIR/$SCHEME_MAIN-Release \
  -exportOptionsPlist ExportOptions.plist \
  -quiet

echo "📁 Preparing DMG contents..."
mkdir -p $BUILD_DIR/dmg-contents
cp -R $BUILD_DIR/$SCHEME_MAIN-Release/*.app $BUILD_DIR/dmg-contents/
ln -s /Applications $BUILD_DIR/dmg-contents/Applications

# Create installation instructions
cat > $BUILD_DIR/dmg-contents/README.txt << EOF
F1r3drive Extensions v0.1.0

INSTALLATION:
1. Drag RevFolderUnlockerApp to the Applications folder
2. Launch RevFolderUnlockerApp.app once to register the extension
3. Go to System Settings > Privacy & Security > Extensions > File Providers
4. Enable "RevFolderUnlockerApp"
5. Restart Finder (Cmd+Option+Esc → Finder → Relaunch)

TROUBLESHOOTING:
- If "File Providers" section is missing or empty, manually run RevFolderUnlockerApp 
  from the Applications folder first, then check Extensions again
- The extension must be enabled to see context menu actions on .token files
- Ensure you have proper permissions for the mounted volumes

FEATURES:
- Right-click context menu "Change" action for .token files in MacFUSE mounts
- Automatic folder unlocking for "LOCKED-REMOTE-REV-" prefixed folders
- Secure private key input interface
- Custom URL scheme support (f1r3drive://)

USAGE:
- Mount your MacFUSE volumes
- Right-click on .token files to see "Change" option
- Navigate to folders with "LOCKED-REMOTE-REV-" prefix to auto-launch unlocker
- Use the app for secure Rev address folder unlocking

REQUIREMENTS:
- macOS 10.15 or later
- MacFUSE for mount detection
- Proper system permissions

For support, visit: https://github.com/f1r3fly/f1r3drive-extension
EOF

echo "💿 Creating DMG..."
hdiutil create -volname "$DMG_NAME" \
  -srcfolder $BUILD_DIR/dmg-contents \
  -ov -format UDZO \
  $BUILD_DIR/$DMG_NAME.dmg

echo "✅ Build complete! DMG created: $BUILD_DIR/$DMG_NAME.dmg"
echo "📁 Size: $(du -h $BUILD_DIR/$DMG_NAME.dmg | cut -f1)"