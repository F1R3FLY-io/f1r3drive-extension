//
//  FinderSync.swift
//  FinderSyncExtension
//
//  Created by Andrii Stefaniv on 08.05.2025.
//

import Cocoa
import FinderSync
import GRPCCore
import SwiftProtobuf
import NIO
import GRPCNIOTransportHTTP2
import Foundation

class FinderSyncExtension: FIFinderSync {
    
    override init() {
        super.init()
        NSLog("FinderSync() launched from %@ :: %@", Bundle.main.bundleIdentifier ?? "Unknown", Bundle.main.bundlePath)
        
        // Get all mounted volumes
        let mountedVolumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeIsRemovableKey, .volumeIsEjectableKey], options: [])
        NSLog("FinderSync: All mounted volumes: %@", (mountedVolumes ?? []).map { $0.path } as CVarArg)
        
        // Log file system type for each mount
        mountedVolumes?.forEach { url in
            if let resourceValues = try? url.resourceValues(forKeys: [.volumeLocalizedFormatDescriptionKey]),
               let fsType = resourceValues.volumeLocalizedFormatDescription {
                NSLog("FinderSync: Volume %@ has format description: %@", url.path as NSString, fsType as NSString)
            } else {
                NSLog("FinderSync: Volume %@ has unknown format description", url.path as NSString)
            }
        }
        
        // Filter for MacFUSE mounts by format description
        let macFuseMounts = mountedVolumes?.filter { url in
            if let resourceValues = try? url.resourceValues(forKeys: [.volumeLocalizedFormatDescriptionKey]),
               let fsType = resourceValues.volumeLocalizedFormatDescription?.lowercased() {
                return fsType.contains("fuse")
            }
            return false
        } ?? []
        
        if macFuseMounts.isEmpty {
            NSLog("FinderSync: No MacFUSE mounts found")
        } else {
            NSLog("FinderSync: Found MacFUSE mounts: %@", macFuseMounts.map { $0.path } as CVarArg)
            FIFinderSyncController.default().directoryURLs = Set(macFuseMounts)
        }
        
        // Set up a timer to periodically check for new MacFUSE mounts
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.updateMacFuseMounts()
        }
    }
    
    private func updateMacFuseMounts() {
        let mountedVolumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeIsRemovableKey, .volumeIsEjectableKey], options: [])
        
        let macFuseMounts = mountedVolumes?.filter { url in
            let resourceValues = try? url.resourceValues(forKeys: [.volumeIsRemovableKey, .volumeIsEjectableKey])
            let isRemovable = resourceValues?.volumeIsRemovable ?? false
            let isEjectable = resourceValues?.volumeIsEjectable ?? false
            return isRemovable && isEjectable
        } ?? []
        
        if !macFuseMounts.isEmpty {
            NSLog("FinderSync: Updating MacFUSE mounts: %@", macFuseMounts.map { $0.path } as CVarArg)
            FIFinderSyncController.default().directoryURLs = Set(macFuseMounts)
        }
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
            let menuItem = NSMenuItem(title: "Change", action: #selector(handleChangeAction(_:)), keyEquivalent: "")
            let iconImage = NSImage(named: "f1r3fly_icon")
            if iconImage == nil {
                NSLog("FinderSync: Failed to load f1r3fly_icon.")
            }
            menuItem.image = iconImage
            menu.addItem(menuItem)
        }
        
        return menu
    }
    
    @objc func handleChangeAction(_ sender: AnyObject?) {
        guard let items = FIFinderSyncController.default().selectedItemURLs() else {
            NSLog("changeAction triggered but no selected items found.")
            return
        }
        
        NSLog("Change action triggered for items:")
        for url in items {
            if url.pathExtension.lowercased() == "token" {
                NSLog("  - %@ (is a .token file)", url.path as NSString)
                Task {
                    do {
                        try await withGRPCClient(
                            transport: .http2NIOPosix(
                                target: .dns(host: "localhost", port: 54000),
                                transportSecurity: .plaintext
                            )
                        ) { client in
                            let grpcClient = Generic_FinderSyncExtensionService.Client(wrapping: client)
                            var request = Generic_MenuActionRequest()
                            request.path = [url.path]
                            request.action = .change
                            _ = try await grpcClient.submitAction(request)
                            NSLog("gRPC: Successfully sent Change action for %@", url.path as NSString)
                        }
                    } catch {
                        NSLog("gRPC: Failed to send Change action for %@: %@", url.path as NSString, String(describing: error))
                    }
                }
            } else {
                NSLog("  - %@ (not a .token file, skipped)", url.path as NSString)
            }
        }
    }
    
    // MARK: - Directory observation for "locked" folder
    override func beginObservingDirectory(at url: URL) {
        if url.lastPathComponent.starts(with: "LOCKED-REMOTE-REV-") {
            NSLog("FinderSync: 'REV' folder opened at %@", url.path as NSString)
            let revAddress = url.lastPathComponent.replacingOccurrences(of: "LOCKED-REMOTE-REV-", with: "")
            launchPrivateKeyHelper(revAddress: revAddress)
        }
    }
    
    func launchPrivateKeyHelper(revAddress: String) {
        // Use custom URL scheme to pass revAddress
        if let url = URL(string: "f1r3drive://unlock?revAddress=\(revAddress)") {
            NSWorkspace.shared.open(url)
        } else {
            NSLog("Failed to construct custom URL for revAddress: %@", revAddress as NSString)
        }
    }
    
    // Removed toolbarItemName, toolbarItemToolTip, toolbarItemImage
    // Removed beginObservingDirectory, endObservingDirectory, requestBadgeIdentifier
    // to keep it minimal and remove the yellow icon and unnecessary logging.
}

