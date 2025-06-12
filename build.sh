#!/bin/bash

set -e

PROJECT_NAME="F1r3driveExtensions"
SCHEME_MAIN="contextmenu"
SCHEME_UNLOCKER="RevFolderUnlockerApp"
BUILD_DIR="build"
DMG_NAME="F1r3drive-Extensions"

echo "🧹 Cleaning previous builds..."
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

echo "📦 Building main app..."
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

echo "📦 Building RevFolderUnlockerApp..."
xcodebuild archive \
  -project $PROJECT_NAME.xcodeproj \
  -scheme $SCHEME_UNLOCKER \
  -archivePath $BUILD_DIR/$SCHEME_UNLOCKER.xcarchive \
  -configuration Release \
  -quiet

xcodebuild -exportArchive \
  -archivePath $BUILD_DIR/$SCHEME_UNLOCKER.xcarchive \
  -exportPath $BUILD_DIR/$SCHEME_UNLOCKER-Release \
  -exportOptionsPlist ExportOptions.plist \
  -quiet

echo "📁 Preparing DMG contents..."
mkdir -p $BUILD_DIR/dmg-contents
cp -R $BUILD_DIR/$SCHEME_MAIN-Release/*.app $BUILD_DIR/dmg-contents/
cp -R $BUILD_DIR/$SCHEME_UNLOCKER-Release/*.app $BUILD_DIR/dmg-contents/
ln -s /Applications $BUILD_DIR/dmg-contents/Applications

# Create installation instructions
cat > $BUILD_DIR/dmg-contents/README.txt << EOF
F1r3drive Extensions v1.0

INSTALLATION:
1. Drag both apps to the Applications folder
2. Open contextmenu.app once to register it
3. Go to System Settings > Privacy & Security > Extensions > Finder Extensions
4. Enable "FinderSyncExtension"
5. Restart Finder (Cmd+Option+Esc → Finder → Relaunch)

USAGE:
- Right-click on .token files in MacFUSE mounts to see "Change" option
- Folders with "LOCKED-REMOTE-REV-" prefix will auto-launch the unlocker

For support, visit: https://github.com/f1r3fly/contextmenu
EOF

echo "💿 Creating DMG..."
hdiutil create -volname "$DMG_NAME" \
  -srcfolder $BUILD_DIR/dmg-contents \
  -ov -format UDZO \
  $BUILD_DIR/$DMG_NAME.dmg

echo "✅ Build complete! DMG created: $BUILD_DIR/$DMG_NAME.dmg"
echo "📁 Size: $(du -h $BUILD_DIR/$DMG_NAME.dmg | cut -f1)"