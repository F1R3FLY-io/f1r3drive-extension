# F1r3drive Extension Features

## 1. Finder Context Menus
- **Target**: `.token` files.
- **Action**: "Change" context menu option.
- **Mechanism**: Selecting "Change" triggers a gRPC call (`SubmitAction`) to `localhost:54000`.

## 2. Folder Unlocking
- **Target**: Directories prefixed with `LOCKED-REMOTE-REV-`.
- **Trigger**: User navigation into the target directory.
- **Mechanism**: Launches `RevFolderUnlockerApp` prompting for a private key. Validates via gRPC (`UnlockWalletFolder`). On success, the folder unlocks.

## 3. MacFUSE Mount Monitoring
- **Target**: Mounted MacFUSE volumes.
- **Mechanism**: 5-second interval polling detects newly mounted volumes to bind the Finder Sync extension.

## 4. Custom URL Scheme (`f1r3drive://`)
- **Target**: Invocations from the main `f1r3drive` app or external tooling.
- **Action**: Supports direct folder unlock requests.
- **Format**: `f1r3drive://unlock?revAddress=<ADDRESS>`.

## 5. Security Context
- **Execution**: Extension and App run within macOS App Sandbox.
- **Bundle ID (App)**: `io.f1r3fly.f1r3drive.RevFolderUnlockerApp`
- **Bundle ID (Extension)**: `io.f1r3fly.f1r3drive.RevFolderUnlockerApp.FinderSyncExtension`
