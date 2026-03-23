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
    
    /// DispatchSource watching /Volumes for filesystem changes (primary mechanism)
    private var volumesWatcher: DispatchSourceFileSystemObject?
    
    /// Coalescing work item to debounce rapid-fire rescan triggers
    private var pendingRescan: DispatchWorkItem?
    
    override init() {
        super.init()
        NSLog("FinderSync() launched from %@ :: %@", Bundle.main.bundleIdentifier ?? "Unknown", Bundle.main.bundlePath)
        
        // Set up mount/unmount notifications (fast-path, but unreliable in sandbox)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(volumeDidMount(_:)),
            name: NSWorkspace.didMountNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(volumeDidUnmount(_:)),
            name: NSWorkspace.didUnmountNotification,
            object: nil
        )
        
        // Initial scan for existing mounts
        updateMacFuseMounts()
        
        // Primary: Watch /Volumes directory for changes (instant reaction via kqueue)
        startWatchingVolumes()
    }
    
    deinit {
        volumesWatcher?.cancel()
        pendingRescan?.cancel()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Mount detection: DispatchSource watcher on /Volumes
    
    private func startWatchingVolumes() {
        let fd = open("/Volumes", O_EVTONLY)
        guard fd >= 0 else {
            NSLog("FinderSync: Failed to open /Volumes for watching (fd=%d)", fd)
            return
        }
        
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .link, .rename],
            queue: .main
        )
        
        source.setEventHandler { [weak self] in
            self?.scheduleRescan()
        }
        
        source.setCancelHandler {
            close(fd)
        }
        
        source.resume()
        volumesWatcher = source
        NSLog("FinderSync: Started watching /Volumes for mount changes")
    }
    
    /// Debounces rapid-fire rescan triggers (e.g. multiple DispatchSource events for a single mount)
    private func scheduleRescan() {
        pendingRescan?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.updateMacFuseMounts()
        }
        pendingRescan = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: work)
    }
    
    // MARK: - Mount detection: NSWorkspace notifications (fast-path)
    
    @objc private func volumeDidMount(_ notification: Notification) {
        guard let devicePath = notification.userInfo?["NSDevicePath"] as? String else {
            return
        }
        NSLog("FinderSync: Volume mounted at %@", devicePath as NSString)
        scheduleRescan()
    }
    
    @objc private func volumeDidUnmount(_ notification: Notification) {
        guard let devicePath = notification.userInfo?["NSDevicePath"] as? String else {
            return
        }
        NSLog("FinderSync: Volume unmounted at %@", devicePath as NSString)
        scheduleRescan()
    }
    
    // MARK: - Mount scanning
    
    private func isMacFuseMount(url: URL) -> Bool {
        if let resourceValues = try? url.resourceValues(forKeys: [.volumeLocalizedFormatDescriptionKey]),
           let fsType = resourceValues.volumeLocalizedFormatDescription?.lowercased() {
            return fsType.contains("fuse")
        }
        return false
    }
    
    private func updateMacFuseMounts() {
        // Get all mounted volumes
        let mountedVolumes = FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: [.volumeIsRemovableKey, .volumeIsEjectableKey, .volumeLocalizedFormatDescriptionKey],
            options: []
        )
        
        // Filter for MacFUSE mounts by format description
        let macFuseMounts = mountedVolumes?.filter { url in
            return isMacFuseMount(url: url)
        } ?? []
        
        let newSet = Set(macFuseMounts)
        let currentSet = FIFinderSyncController.default().directoryURLs ?? Set()
        
        // Only update if the set of observed directories actually changed
        if newSet != currentSet {
            let added = newSet.subtracting(currentSet)
            let removed = currentSet.subtracting(newSet)
            
            if !added.isEmpty {
                NSLog("FinderSync: New MacFUSE mounts detected: %@", added.map { $0.path } as CVarArg)
            }
            if !removed.isEmpty {
                NSLog("FinderSync: Stale MacFUSE mounts removed: %@", removed.map { $0.path } as CVarArg)
            }
            
            FIFinderSyncController.default().directoryURLs = newSet
            NSLog("FinderSync: Now observing %d MacFUSE mount(s): %@", newSet.count, newSet.map { $0.path } as CVarArg)
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
    
    // MARK: - Badge identifier for .token files
    override func requestBadgeIdentifier(for url: URL) {
        NSLog("FinderSync: requestBadgeIdentifier called for %@", url.path as NSString)
        
        // Check if this is a .token file
        if url.pathExtension.lowercased() == "token" {
            NSLog("FinderSync: Setting badge for .token file: %@", url.path as NSString)
            FIFinderSyncController.default().setBadgeIdentifier("f1r3fly_badge", for: url)
        }
    }
}

