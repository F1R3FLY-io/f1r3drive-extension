## F1r3drive Extensions v0.1.0

### 🚀 Features
- **Context Menu Integration**: Right-click "Change" action for .token files in MacFUSE mounts
- **Auto-Unlock**: Automatic folder unlocking for "LOCKED-REMOTE-REV-" prefixed folders
- **Secure Input**: Safe private key input interface with proper validation
- **URL Scheme Support**: Custom f1r3drive:// URL scheme for deep linking
- **FinderSync Extension**: Native macOS Finder extension for seamless integration

### 📦 Installation Instructions
1. **Download** the DMG file from this release
2. **Mount** the DMG and drag `RevFolderUnlockerApp` to your Applications folder
3. **Launch** the app once to register the system extension
4. **Enable Extension**: 
   - Go to System Settings → Privacy & Security → Extensions → File Providers
   - Enable "RevFolderUnlockerApp"
5. **Restart Finder**: Press Cmd+Option+Esc → Select Finder → Click Relaunch

### 🔧 Usage
- Mount your MacFUSE volumes containing encrypted folders
- Right-click on `.token` files to see the "Change" context menu option
- Navigate to folders with "LOCKED-REMOTE-REV-" prefix to trigger auto-unlock
- Use the secure interface to input your private key for folder decryption

### 🛠️ Troubleshooting
- **Missing File Providers section**: Launch RevFolderUnlockerApp manually first
- **Context menu not appearing**: Ensure the extension is enabled and Finder is restarted
- **Auto-unlock not working**: Verify MacFUSE is properly installed and volumes are mounted
- **Permission issues**: Check that the app has necessary system permissions

### 📋 Requirements
- **macOS**: 10.15 (Catalina) or later
- **MacFUSE**: Required for mount detection and volume operations
- **Permissions**: System extension permissions and file access

### 🐛 Known Issues
- First-time setup requires manual extension activation
- Some macOS versions may require additional security permissions

### 💬 Support
For issues, feature requests, or contributions, please visit our [GitHub repository](https://github.com/f1r3fly/f1r3drive-extension).

---
**Checksum**: Will be updated automatically upon release 