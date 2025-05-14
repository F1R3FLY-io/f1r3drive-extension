# contextmenu

A macOS Finder Sync extension and SwiftUI app for customizing the Finder context menu, with a focus on supporting custom actions for `.token` files.

## Features

- **Finder Context Menu Customization:**
  - Adds a custom "Change" action to the Finder context menu for files with the `.token` extension.
  - (Other actions: **TODO** — planned for future development.)
- **SwiftUI App:**
  - Basic SwiftUI app structure (currently a placeholder UI).

## Project Structure

- [`contextmenu/`](contextmenu/) — Main SwiftUI app
  - [`ContentView.swift`](contextmenu/ContentView.swift): Main SwiftUI view
  - [`contextmenuApp.swift`](contextmenu/contextmenuApp.swift): App entry point
  - [`contextmenu.entitlements`](contextmenu/contextmenu.entitlements): App entitlements
  - [`Assets.xcassets/`](contextmenu/Assets.xcassets): Asset catalog for images/resources
- [`TokenFile/`](TokenFile/) — Finder Sync extension
  - [`FinderSync.swift`](TokenFile/FinderSync.swift): Finder Sync extension logic (context menu customization)
  - [`Info.plist`](TokenFile/Info.plist): Extension configuration (registers `.token` file type)
  - [`TokenFile.entitlements`](TokenFile/TokenFile.entitlements): Extension entitlements
- [`contextmenuTests/`](contextmenuTests/) — Unit tests for the main app
- [`contextmenuUITests/`](contextmenuUITests/) — UI tests for the main app
- [`Media.xcassets/`](Media.xcassets/) — Additional image assets (e.g., `f1r3fly_icon`)
- [`.cursor/rules/`](.cursor/rules/) — Project-specific rules and structure guides

## How It Works

- The Finder Sync extension observes all directories and adds a "Change" menu item for `.token` files in Finder's context menu.
- Selecting "Change" triggers a simple alert (for demonstration). Future versions will add more actions and logic.

## Setup & Development

### Prerequisites
- [Xcode](https://developer.apple.com/xcode/) (latest recommended)
- macOS with support for Finder Sync extensions

### Running Locally

1. **Clone the repository:**
   ```sh
   git clone <your-repo-url>
   cd contextmenu
   ```
2. **Open the project in Xcode:**
   - Open [`contextmenu.xcodeproj`](contextmenu.xcodeproj/) in Xcode.
3. **Build the app and extension:**
   - Select the `contextmenu` scheme and build (⌘B).
   - Select the `TokenFile` extension scheme and build if needed.
4. **Enable the Finder Sync extension:**
   - Go to **System Settings > Privacy & Security > Extensions > Finder Extensions**.
   - Enable the `TokenFile` extension.
5. **Run the app:**
   - Run the `contextmenu` app from Xcode (⌘R) for UI testing or development.
   - The Finder Sync extension will be available in Finder context menus for `.token` files.
6. **Testing:**
   - Run unit and UI tests using Xcode's test navigator.
   - Test the context menu by right-clicking `.token` files in Finder and selecting **Change**.

## Contribution & Rules

- Follow the guidelines in [`.cursor/rules/`](.cursor/rules/) for project structure and contributions.
- Keep code simple, focused, and well-documented.
- See [`contextmenuTests/`](contextmenuTests/) and [`contextmenuUITests/`](contextmenuUITests/) for test examples.

