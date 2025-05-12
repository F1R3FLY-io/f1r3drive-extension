//
//  FinderSync.swift
//  TokenFile
//
//  Created by Andrii Stefaniv on 08.05.2025.
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    
    override init() {
        super.init()
        NSLog("FinderSync() launched from %@ :: %@", Bundle.main.bundleIdentifier ?? "Unknown", Bundle.main.bundlePath)
        
        // Monitor all directories.
        // Using "/" might be too broad and could have performance implications
        // or require special permissions. For a more targeted approach,
        // consider observing specific user directories like ~/Downloads, ~/Documents, etc.
        // or allowing the user to specify directories.
        // For this example, we'll try to observe all accessible locations.
        FIFinderSyncController.default().directoryURLs = Set([URL(fileURLWithPath: "/")])
        
        // If issues persist with "/", try more specific common locations:
        // let userDirs = [
        //     FileManager.default.homeDirectoryForCurrentUser,
        //     URL(fileURLWithPath: "/Users/Shared", isDirectory: true)
        // ]
        // FIFinderSyncController.default().directoryURLs = Set(userDirs)

        NSLog("FinderSync observing directories: %@", FIFinderSyncController.default().directoryURLs as CVarArg)

    }
    
    // MARK: - Menu and toolbar item support
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let menu = NSMenu(title: "")
        
        // Ensure we have selected items and that we are in the context menu for items
        guard menuKind == .contextualMenuForItems,
              let selectedItems = FIFinderSyncController.default().selectedItemURLs() else {
            return menu
        }
        
        // Check if any of the selected items have a ".token" extension
        let hasTokenFile = selectedItems.contains { url in
            return url.pathExtension.lowercased() == "token"
        }
        
        if hasTokenFile {
            let menuItem = NSMenuItem(title: "Change", action: #selector(changeAction(_:)), keyEquivalent: "")
            let iconImage = NSImage(named: "f1r3fly_icon")
            if iconImage == nil {
                NSLog("FinderSync: Failed to load f1r3fly_icon.")
            }
            menuItem.image = iconImage
            menu.addItem(menuItem)
        }
        
        return menu
    }
    
    @objc func changeAction(_ sender: AnyObject?) {
        guard let items = FIFinderSyncController.default().selectedItemURLs() else {
            NSLog("changeAction triggered but no selected items found.")
            return
        }
        
        NSLog("Change action triggered for items:")
        for url in items {
            if url.pathExtension.lowercased() == "token" {
                NSLog("  - %@ (is a .token file)", url.path as NSString)
                
                // Example: Show an alert
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Change Token File"
                    alert.informativeText = "Change action triggered for: \(url.lastPathComponent)"
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
            } else {
                NSLog("  - %@ (not a .token file, skipped)", url.path as NSString)
            }
        }
    }
    
    // Removed toolbarItemName, toolbarItemToolTip, toolbarItemImage
    // Removed beginObservingDirectory, endObservingDirectory, requestBadgeIdentifier
    // to keep it minimal and remove the yellow icon and unnecessary logging.
}

