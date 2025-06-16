# F1r3drive Extensions

A comprehensive macOS Finder extension suite that enhances file management for the F1r3drive ecosystem. This project provides custom context menu actions, folder unlocking capabilities, and seamless integration with MacFUSE mounts.

## 🚀 Features

- **Smart Context Menus**: Custom "Change" action for `.token` files in Finder
- **Automatic Folder Unlocking**: Detects and unlocks Rev address folders with private keys
- **MacFUSE Integration**: Seamless detection and monitoring of mounted volumes
- **Secure Interface**: Modern SwiftUI-based private key input with proper sandboxing
- **URL Scheme Support**: Custom `f1r3drive://` protocol for inter-app communication
- **Real-time Monitoring**: Automatic detection of locked folder access attempts

## 📦 Installation

### Quick Install (Recommended)

1. **Download** the latest release DMG
2. **Drag** `RevFolderUnlockerApp` to your Applications folder
3. **Launch** `RevFolderUnlockerApp.app` once to register the extension
4. **Enable Extension**:
   - Go to **System Settings > Privacy & Security > Extensions > File Providers**
   - Enable "RevFolderUnlockerApp"
5. **Restart Finder** (Cmd+Option+Esc → Finder → Relaunch)

### Troubleshooting Installation

- **File Providers section missing?** Manually run RevFolderUnlockerApp from Applications folder first
- **Extension not appearing?** Check that the app is properly signed and in Applications folder
- **Context menu not working?** Ensure MacFUSE volumes are properly mounted and accessible

## 🔧 Building from Source

### Prerequisites

- **Xcode 15.0+** (latest recommended)
- **macOS 12.0+** with Finder extension support
- **MacFUSE** (for testing mount detection)
- **Swift 5.0+**

### Build Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/f1r3fly/f1r3drive-extension.git
   cd f1r3drive-extension
   ```

2. **Open in Xcode:**
   ```bash
   open F1r3driveExtensions.xcodeproj
   ```

3. **Build the project:**
   ```bash
   # Using the build script (creates DMG)
   ./build.sh
   
   # Or build manually in Xcode
   # Select RevFolderUnlockerApp scheme and build
   ```

4. **Enable File Provider Extension:**
   - Go to **System Settings > Privacy & Security > Extensions > File Providers**
   - Enable the `RevFolderUnlockerApp` extension

## 🎯 Usage

### Context Menu Actions

1. **Mount MacFUSE volumes** containing `.token` files
2. **Right-click** on any `.token` file in Finder
3. **Select "Change"** from the context menu
4. The action will be processed via gRPC communication

### Folder Unlocking

1. **Navigate** to folders starting with `LOCKED-REMOTE-REV-`
2. The **RevFolderUnlockerApp will launch automatically**
3. **Enter your private key** in the secure interface
4. The folder will be unlocked for access

### URL Scheme Testing

Test the custom URL scheme with:
```bash
open "f1r3drive://unlock?revAddress=111129p33f7vaRrpLqK8Nr35Y2aacAjrR5pd6PCzqcdrMuPHzymczH"
```

## 🏗️ Architecture

### Core Components

- **`RevFolderUnlockerApp/`** — Main SwiftUI application
  - Modern interface for private key input
  - URL scheme handling (`f1r3drive://`)
  - Secure credential management

- **`FinderSyncExtension/`** — Finder integration layer
  - Context menu enhancement for `.token` files
  - MacFUSE mount detection and monitoring
  - gRPC client for backend communication
  - Directory observation for locked folders

- **`Protos/`** — Protocol definitions
  - gRPC service definitions
  - Protocol buffer schemas
  - Swift code generation configuration

### Technical Details

- **gRPC Communication**: Service-based architecture on `localhost:54000`
- **Real-time Monitoring**: 5-second interval MacFUSE mount detection
- **Security**: Sandboxed execution with proper entitlements
- **Performance**: Async/await patterns with SwiftNIO

## 🔌 Integration

### gRPC Service Requirements

For full functionality, implement a gRPC server on `localhost:54000` with:

```protobuf
service FinderSyncExtensionService {
  rpc SubmitAction(MenuActionRequest) returns (MenuActionResponse);
  rpc UnlockWalletFolder(UnlockWalletFolderRequest) returns (UnlockWalletFolderResponse);
}
```

### Bundle Identifiers

- **Main App**: `io.f1r3fly.f1r3drive.RevFolderUnlockerApp`
- **Finder Extension**: `io.f1r3fly.f1r3drive.RevFolderUnlockerApp.FinderSyncExtension`

## 🧪 Testing

### Build and Runtime Testing

**Build Verification:**
```bash
# Build all targets
xcodebuild -project F1r3driveExtensions.xcodeproj -scheme RevFolderUnlockerApp -configuration Debug build
xcodebuild -project F1r3driveExtensions.xcodeproj -scheme FinderSyncExtension -configuration Debug build

# Create release build with signing
./build.sh
```

**Extension Installation Testing:**
```bash
# Install and enable the extension
cp -r build/RevFolderUnlockerApp.app /Applications/
open /Applications/RevFolderUnlockerApp.app

# Verify extension is registered (check System Settings > Extensions > File Providers)
pluginkit -m -A -D -v | grep FinderSyncExtension
```

### Manual Testing

**Context Menu Integration:**
```bash
# 1. Create test MacFUSE mount with .token files
mkdir -p /tmp/test-mount
echo "test-token-content" > /tmp/test-mount/test.token

# 2. Mount via MacFUSE (requires actual MacFUSE setup)
# 3. Navigate to mounted volume in Finder
# 4. Right-click on .token file
# 5. Verify "Change" option appears in context menu
```

**Folder Unlocking Workflow:**
```bash
# 1. Create test locked folder
mkdir "LOCKED-REMOTE-REV-1111LAd2PWaHsw84gxarNx99YVK2aZhCThhrPsWTV7cs1BPcvHftP"

# 2. Navigate to folder in Finder
# 3. Verify RevFolderUnlockerApp launches automatically
# 4. Test private key input interface
```

**URL Scheme Testing:**
```bash
# Test custom URL scheme handling
open "f1r3drive://unlock?revAddress=111129p33f7vaRrpLqK8Nr35Y2aacAjrR5pd6PCzqcdrMuPHzymczH"

# Verify app launches and processes URL parameters
```

### Integration Testing

**gRPC Service Testing:**
```bash
# Requires a mock gRPC server running on localhost:54000
# Test service endpoints:
# - SubmitAction (MenuActionRequest)
# - UnlockWalletFolder (UnlockWalletFolderRequest)

# Start mock server (implementation dependent)
# Then test extension context menu actions
```

**MacFUSE Integration:**
```bash
# 1. Install MacFUSE
# 2. Create test mounts with .token files
# 3. Verify extension detects mounts every 5 seconds
# 4. Test context menu functionality on mounted volumes
```

### Development and Debugging

**Xcode Testing:**
```bash
# Run individual schemes for debugging
xcodebuild -project F1r3driveExtensions.xcodeproj -scheme contextmenu -configuration Debug

# Debug FinderSync extension
xcodebuild -project F1r3driveExtensions.xcodeproj -scheme FinderSyncExtension -configuration Debug
```

**Console Debugging:**
```bash
# Monitor system logs for extension activity
log stream --predicate 'subsystem contains "io.f1r3fly.f1r3drive"' --level debug

# Check extension loading status
sudo log show --predicate 'eventMessage contains "FinderSyncExtension"' --last 1h
```

### Test Automation

**Note**: This project currently lacks automated unit and UI test targets. To add comprehensive testing:

1. **Add Unit Tests**: Create test targets for core functionality
2. **Add UI Tests**: Test SwiftUI interfaces and user workflows  
3. **Add Integration Tests**: Test gRPC communication and file system interactions
4. **CI/CD**: Set up automated testing pipeline with GitHub Actions

**Recommended Test Structure:**
```
├── RevFolderUnlockerAppTests/          # Unit tests for main app
├── FinderSyncExtensionTests/           # Unit tests for extension
├── F1r3driveExtensionsUITests/         # UI automation tests
└── IntegrationTests/                   # End-to-end testing
```

## 📋 Requirements

- **macOS 12.0+** (Monterey or later)
- **MacFUSE** for mount detection features
- **Xcode 15.0+** for development
- **Network access** for gRPC communication (localhost:54000)

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Test** your changes thoroughly
4. **Commit** with clear messages (`git commit -m 'Add amazing feature'`)
5. **Push** to the branch (`git push origin feature/amazing-feature`)
6. **Open** a Pull Request

### Development Guidelines

- Follow Swift coding conventions
- Test both Finder extension and main app functionality
- Ensure gRPC integration works properly
- Update protocol buffer definitions when needed
- Test with actual MacFUSE mounts

## 📄 License

This project is part of the F1r3drive ecosystem. See the LICENSE file for details.

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/f1r3fly/f1r3drive-extension/issues)
- **Documentation**: Check the individual component READMEs
- **Community**: F1r3drive Discord/Forums

---

**Note**: This extension requires proper system permissions and may need to be re-enabled after macOS updates.

