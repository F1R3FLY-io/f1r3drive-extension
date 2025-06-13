# RevFolderUnlockerApp

A secure macOS application for unlocking Rev address folders with private keys. This app provides a modern SwiftUI interface and handles custom URL schemes for seamless integration with the F1r3drive ecosystem.

## 🚀 Features

- **Secure Private Key Input**: Uses SwiftUI's SecureField for safe credential entry
- **Custom URL Scheme**: Handles `f1r3drive://` URLs for automated unlocking workflows
- **Clipboard Integration**: One-click copying of Rev addresses
- **Modern Interface**: Clean, intuitive SwiftUI design with proper spacing and styling
- **Sandboxed Security**: Runs in a secure macOS sandbox environment
- **Automatic Launch**: Triggered by folder access patterns in Finder

## 📦 Installation

### From DMG (Recommended)
1. Download the F1r3drive Extensions DMG
2. Drag `RevFolderUnlockerApp` to your Applications folder
3. Launch the app once to register the extension
4. Enable in System Settings > Privacy & Security > Extensions > File Providers

### From Source
```bash
# Clone and build the project
git clone https://github.com/f1r3fly/f1r3drive-extension.git
cd f1r3drive-extension
open F1r3driveExtensions.xcodeproj

# Build the RevFolderUnlockerApp target
# Copy to Applications folder
cp -r ~/Library/Developer/Xcode/DerivedData/*/Build/Products/Debug/RevFolderUnlockerApp.app /Applications/
```

## 🎯 Usage

### Manual Launch
1. Open the app from Applications folder
2. Enter the Rev address manually or copy/paste
3. Input your private key securely
4. Click "Unlock" to process the request

### Automatic Launch (via URL Scheme)
The app automatically launches when:
- Navigating to folders with `LOCKED-REMOTE-REV-` prefix in Finder
- Clicking custom links with `f1r3drive://` protocol
- Receiving URL scheme calls from other F1r3drive components

### URL Scheme Format
```
f1r3drive://unlock?revAddress=<REV_ADDRESS>
```

**Example:**
```bash
open "f1r3drive://unlock?revAddress=111129p33f7vaRrpLqK8Nr35Y2aacAjrR5pd6PCzqcdrMuPHzymczH"
```

## 🔧 Technical Details

### Bundle Information
- **Bundle Identifier**: `io.f1r3fly.f1r3drive.RevFolderUnlockerApp`
- **URL Scheme**: `f1r3drive`
- **Minimum macOS**: 12.0 (Monterey)
- **Architecture**: Universal (Apple Silicon + Intel)

### Security Features
- **Sandboxed Execution**: Runs with limited system access
- **Secure Input**: Private keys are handled securely in memory
- **Entitlements**: Minimal required permissions
- **Code Signing**: Properly signed for macOS security

### Integration Points
- **Finder Extension**: Receives unlock requests from FinderSyncExtension
- **URL Handling**: Processes custom `f1r3drive://` URLs
- **Clipboard**: Secure copy operations for Rev addresses
- **System Integration**: Proper macOS app lifecycle management

## 🧪 Testing

### Manual Testing
```bash
# Test URL scheme handling
open "f1r3drive://unlock?revAddress=111129p33f7vaRrpLqK8Nr35Y2aacAjrR5pd6PCzqcdrMuPHzymczH"

# Test folder detection
mkdir "LOCKED-REMOTE-REV-111129p33f7vaRrpLqK8Nr35Y2aacAjrR5pd6PCzqcdrMuPHzymczH"
open "LOCKED-REMOTE-REV-111129p33f7vaRrpLqK8Nr35Y2aacAjrR5pd6PCzqcdrMuPHzymczH"
```

### Validation Checklist
- [ ] App launches from Applications folder
- [ ] URL scheme handling works correctly
- [ ] Rev address auto-populates from URL
- [ ] Private key input is secure (masked)
- [ ] Copy to clipboard functionality works
- [ ] UI responds properly to user interactions

## 🔒 Security Considerations

- **Private Key Handling**: Keys are never logged or persisted
- **Memory Management**: Secure cleanup of sensitive data
- **Sandbox Restrictions**: Limited file system and network access
- **URL Validation**: Proper validation of incoming URL scheme data
- **User Consent**: All operations require explicit user action

## 🛠️ Development

### Building
```bash
# Open project in Xcode
open F1r3driveExtensions.xcodeproj

# Select RevFolderUnlockerApp scheme
# Build for your target architecture
```

### Debugging
- Use Xcode's debugger for stepping through code
- Check Console.app for system-level logs
- Monitor URL scheme handling with Activity Monitor
- Test with various Rev address formats

### Code Structure
- **`RevFolderUnlockerApp.swift`**: Main app entry point and URL handling
- **`ContentView.swift`**: SwiftUI interface and user interactions
- **`Info.plist`**: App configuration and URL scheme registration
- **`RevFolderUnlockerApp.entitlements`**: Security permissions

## 📋 Requirements

- **macOS 12.0+** (Monterey or later)
- **Xcode 15.0+** (for building from source)
- **Valid Rev addresses** for testing
- **Finder extension enabled** for automatic folder detection

## 🆘 Troubleshooting

### Common Issues

**App won't launch from URL scheme:**
- Ensure app is in Applications folder
- Check URL scheme registration in Info.plist
- Verify no other apps are handling `f1r3drive://` URLs

**Extension not working:**
- Enable in System Settings > Extensions > File Providers
- Restart Finder after enabling extension
- Check that RevFolderUnlockerApp is properly installed

**Private key input issues:**
- Ensure secure input field has focus
- Check for keyboard/input method conflicts
- Verify app has proper input permissions

### Support Resources
- [Main Project README](../README.md)
- [GitHub Issues](https://github.com/f1r3fly/f1r3drive-extension/issues)
- F1r3drive community forums

---

**Note**: This app is part of the larger F1r3drive Extensions suite. For full functionality, ensure all components are properly installed and configured. 