# F1r3drive Extensions

A macOS Finder Sync extension suite for the F1r3drive ecosystem, providing custom context menu actions for `.token` files and folder unlocking capabilities. The project consists of multiple integrated components that work together to enhance Finder functionality for blockchain-related file operations.

## Overview

This project provides:
- **Finder Context Menu Enhancement**: Custom actions for `.token` files via a Finder Sync extension
- **MacFUSE Integration**: Automatic detection and monitoring of MacFUSE mounts
- **gRPC Communication**: Service-based architecture for handling menu actions
- **Folder Unlocking UI**: Dedicated app for unlocking Rev address folders with private keys
- **URL Scheme Handling**: Custom `f1r3drive://` URL scheme support

## Project Structure

### Core Components

- **[`contextmenu/`](contextmenu/)** — Main SwiftUI app (minimal placeholder UI)
  - [`ContentView.swift`](contextmenu/ContentView.swift): Basic "Hello, world!" SwiftUI view
  - [`contextmenuApp.swift`](contextmenu/contextmenuApp.swift): App entry point
  - [`contextmenu.entitlements`](contextmenu/contextmenu.entitlements): App entitlements

- **[`FinderSyncExtension/`](FinderSyncExtension/)** — Finder Sync extension with advanced functionality
  - [`FinderSyncExtension.swift`](FinderSyncExtension/FinderSyncExtension.swift): Core extension logic
    - MacFUSE mount detection and monitoring
    - Context menu "Change" action for `.token` files
    - gRPC client for communicating with backend services
    - Directory observation for locked Rev folders
    - Custom URL scheme launching for folder unlocking
  - [`Info.plist`](FinderSyncExtension/Info.plist): Extension configuration
  - [`FinderSyncExtension.entitlements`](FinderSyncExtension/FinderSyncExtension.entitlements): Extension entitlements

- **[`RevFolderUnlockerApp/`](RevFolderUnlockerApp/)** — Dedicated app for folder unlocking
  - [`ContentView.swift`](RevFolderUnlockerApp/ContentView.swift): Modern SwiftUI interface for private key input
  - [`RevFolderUnlockerApp.swift`](RevFolderUnlockerApp/RevFolderUnlockerApp.swift): App entry point with URL scheme handling
  - [`RevFolderUnlockerApp.entitlements`](RevFolderUnlockerApp/RevFolderUnlockerApp.entitlements): App entitlements
  - [`README.md`](RevFolderUnlockerApp/README.md): Detailed documentation for the unlocking app

### Protocol Definitions & Configuration

- **[`Protos/`](Protos/)** — gRPC service definitions
  - [`FinderSyncExntesionService.proto`](Protos/FinderSyncExntesionService.proto): Protocol buffer definitions
    - `MenuActionType` enum (CHANGE, COMBINE)
    - `MenuActionRequest`, `UnlockWalletFolderRequest` messages
    - `FinderSyncExtensionService` with `SubmitAction` and `UnlockWalletFolder` RPCs
  - [`grpc-swift-config.json`](Protos/grpc-swift-config.json): gRPC Swift configuration

- **Project Files**
  - [`F1r3driveExtensions.xcodeproj/`](F1r3driveExtensions.xcodeproj/): Main Xcode project
  - [`grpc-swift-proto-generator-config.json`](grpc-swift-proto-generator-config.json): Proto generation config
  - [`Media.xcassets/`](Media.xcassets/): Shared image assets (f1r3fly_icon)

### Test Suites

- **[`contextmenuTests/`](contextmenuTests/)** — Unit tests for the main app
- **[`contextmenuUITests/`](contextmenuUITests/)** — UI tests for the main app

## Key Features

### 1. MacFUSE Mount Detection
The Finder Sync extension automatically:
- Detects all mounted MacFUSE volumes
- Monitors for new mounts every 5 seconds
- Filters volumes by FUSE format description
- Updates the monitored directory list dynamically

### 2. Context Menu Integration
- Adds "Change" action to Finder context menus for `.token` files
- Displays custom F1r3fly icon in the context menu
- Sends gRPC requests to `localhost:54000` when actions are triggered
- Supports batch operations on multiple selected `.token` files

### 3. Folder Unlocking System
- Detects when folders starting with `LOCKED-REMOTE-REV-` are opened
- Extracts Rev address from folder name
- Launches RevFolderUnlockerApp via custom URL scheme (`f1r3drive://unlock?revAddress=...`)
- Provides secure private key input interface

### 4. gRPC Service Architecture
- Protocol buffer-based communication
- Supports `SubmitAction` for menu actions (CHANGE, COMBINE)
- Supports `UnlockWalletFolder` for folder unlocking operations
- Async/await implementation with proper error handling

## Setup & Development

### Prerequisites
- **Xcode** (latest recommended)
- **macOS** with Finder Sync extension support
- **MacFUSE** (for testing mount detection features)
- **gRPC server** running on `localhost:54000` (for full functionality)

### Building and Running

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd contextmenu
   ```

2. **Open in Xcode:**
   ```bash
   open F1r3driveExtensions.xcodeproj
   ```

3. **Build all targets:**
   - Build the `contextmenu` scheme
   - Build the `FinderSyncExtension` scheme  
   - Build the `RevFolderUnlockerApp` scheme

4. **Enable Finder Sync Extension:**
   - Go to **System Settings > Privacy & Security > Extensions > Finder Extensions**
   - Enable the `FinderSyncExtension` extension

5. **Install RevFolderUnlockerApp:**
   ```bash
   # Copy the built app to Applications folder
   cp -r ~/Library/Developer/Xcode/DerivedData/*/Build/Products/Debug/RevFolderUnlockerApp.app /Applications/
   ```

### Testing

**Context Menu Testing:**
1. Create test `.token` files in a MacFUSE mount
2. Right-click on `.token` files in Finder
3. Look for "Change" option in context menu

**Folder Unlocking Testing:**
1. Create a folder named `LOCKED-REMOTE-REV-<some-address>`
2. Navigate to the folder in Finder
3. The RevFolderUnlockerApp should launch automatically

**URL Scheme Testing:**
```bash
open "f1r3drive://unlock?revAddress=1111LAd2PWaHsw84gxarNx99YVK2aZhCThhrPsWTV7cs1BPcvHftP"
```

### gRPC Service Integration

For full functionality, ensure a gRPC server is running on `localhost:54000` that implements the `FinderSyncExtensionService` protocol defined in [`Protos/FinderSyncExntesionService.proto`](Protos/FinderSyncExntesionService.proto).

## Dependencies

The project uses the following Swift packages:
- **gRPC Swift**: For service communication
- **SwiftProtobuf**: For protocol buffer support
- **SwiftNIO**: For networking (HTTP/2 transport)

## Bundle Identifiers

- Main app: `io.f1r3fly.f1r3drive.contextmenu`
- Finder extension: `io.f1r3fly.f1r3drive.contextmenu.FinderSyncExtension`
- Folder unlocker: `io.f1r3fly.f1r3drive.RevFolderUnlockerApp`

## URL Schemes

- **f1r3drive**: Handled by RevFolderUnlockerApp for folder unlocking operations

## Contributing

When contributing to this project:
- Follow Swift coding conventions
- Test both Finder extension and unlocking app functionality
- Ensure gRPC integration works properly
- Update protocol buffer definitions as needed
- Test with actual MacFUSE mounts when possible

