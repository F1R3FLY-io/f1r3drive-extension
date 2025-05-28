# RevFolderUnlockerApp

A macOS application for unlocking Rev folders with private keys. This app handles custom URL schemes to receive unlock requests.

## Features

- Secure private key input using SwiftUI's SecureField
- Custom URL scheme handling (`f1r3drive://`)
- Copy Rev address to clipboard functionality
- Sandboxed macOS application

## Building the Application

1. Open the project in Xcode
2. Build the project (⌘+B)
3. The built application will be located in Xcode's DerivedData folder

## Installation

After building the project, copy the application to your Applications folder:

```bash
cp -r ~/Library/Developer/Xcode/DerivedData/f1r3drive-extensions-*/Build/Products/Debug/RevFolderUnlockerApp.app /Applications/
```

## Testing

To test the application with a sample Rev address, use the following command:

```bash
open "f1r3drive://unlock?revAddress=1111LAd2PWaHsw84gxarNx99YVK2aZhCThhrPsWTV7cs1BPcvHftP"
```

This will launch the RevFolderUnlockerApp app with the specified Rev address pre-populated.

## URL Scheme

The application responds to URLs with the following format:
```
f1r3drive://unlock?revAddress=<REV_ADDRESS>
```

Where `<REV_ADDRESS>` is the Rev blockchain address that needs to be unlocked.

## Requirements

- macOS 10.15 or later
- Xcode (for building)

## Bundle Information

- Bundle Identifier: `io.f1r3fly.f1r3drive.RevFolderUnlockerApp`
- URL Scheme: `f1r3drive` 