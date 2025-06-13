//
//  ContentView.swift
//  RevFolderUnlockerApp
//
//  Created by Andrii Stefaniv on 27.05.2025.
//

import SwiftUI
import GRPCCore
import SwiftProtobuf
import NIO
import GRPCNIOTransportHTTP2

struct ContentView: View {
    @State private var privateKey: String = ""
    @State private var isHovering: Bool = false
    @State private var showCopiedFeedback: Bool = false
    @State private var isUnlocking: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showSuccess: Bool = false
    var revAddress: String

    var body: some View {
        VStack(spacing: 0) {
            // Header Section
            VStack(spacing: 16) {
                // F1r3fly Icon
                Image("f1r3fly_icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                // Title
                Text("Folder Unlock Required")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                // Subtitle
                Text("Enter your private key to unlock the folder")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // Address Display
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Rev Address")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    Button(action: copyAddress) {
                        HStack(spacing: 8) {
                            Image(systemName: "key.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                            
                            Text(revAddress)
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            
                            Spacer()
                            
                            Image(systemName: showCopiedFeedback ? "checkmark" : "doc.on.doc")
                                .foregroundColor(showCopiedFeedback ? .green : .blue)
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isHovering ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                        )
                        .scaleEffect(isHovering ? 1.02 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: isHovering)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onHover { hovering in
                        isHovering = hovering
                    }
                    .help("Click to copy address to clipboard")
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            
            Spacer()
                .frame(height: 40)
            
            // Input Section
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Private Key")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "lock.shield")
                            .foregroundColor(.orange)
                            .font(.caption)
                        
                        SecureField("Enter your private key...", text: $privateKey)
                            .textFieldStyle(.plain)
                            .focused($isFocused)
                            .disabled(isUnlocking)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.05))
                            .stroke(privateKey.isEmpty ? Color.gray.opacity(0.3) : Color.blue.opacity(0.5), lineWidth: 1)
                    )
                }
                
                // Error Message
                if showError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.1))
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Success Message
                if showSuccess {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("Folder unlocked successfully!")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green.opacity(0.1))
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
                .frame(height: 24)
            
            // Action Buttons
            HStack(spacing: 12) {
                Button("Cancel") {
                    NSApplication.shared.keyWindow?.close()
                }
                .buttonStyle(SecondaryButtonStyle())
                .keyboardShortcut(.cancelAction)
                .disabled(isUnlocking)
                
                Button(action: unlockFolder) {
                    HStack {
                        if isUnlocking {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        Text(isUnlocking ? "Unlocking..." : "Unlock Folder")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .keyboardShortcut(.defaultAction)
                .disabled(privateKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isUnlocking)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(width: 400, height: 450)
        .background(Color(.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    @FocusState private var isFocused: Bool
    
    private func copyAddress() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(revAddress, forType: .string)
        
        showCopiedFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showCopiedFeedback = false
        }
    }
    
    private func unlockFolder() {
        // Reset states
        showError = false
        showSuccess = false
        isUnlocking = true
        
        Task {
            do {
                try await withGRPCClient(
                    transport: .http2NIOPosix(
                        target: .dns(host: "localhost", port: 54000),
                        transportSecurity: .plaintext
                    )
                ) { client in
                    let grpcClient = Generic_FinderSyncExtensionService.Client(wrapping: client)
                    var request = Generic_UnlockWalletDirectoryRequest()
                    request.revAddress = revAddress
                    request.privateKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    let response = try await grpcClient.unlockWalletDirectory(request)
                    
                    await MainActor.run {
                        isUnlocking = false
                        
                        switch response.result {
                        case .success:
                            showSuccess = true
                            // Close the app after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                NSApplication.shared.keyWindow?.close()
                            }
                        case .error(let errorResponse):
                            showError = true
                            errorMessage = errorResponse.errorMessage
                        case .none:
                            showError = true
                            errorMessage = "Unknown error occurred"
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isUnlocking = false
                    showError = true
                    errorMessage = "Failed to connect to service: \(error.localizedDescription)"
                }
            }
        }
    }
}

// Custom Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, weight: .medium))
            .foregroundColor(.primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct AppContentView: View {
    @State private var revAddress: String = "Unknown"
    
    var body: some View {
        ContentView(revAddress: revAddress)
            .onOpenURL { url in
                if url.scheme == "f1r3drive", url.host == "unlock" {
                    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                       let queryItem = components.queryItems?.first(where: { $0.name == "revAddress" }),
                       let value = queryItem.value {
                        revAddress = value
                    }
                }
            }
    }
}

#Preview {
    ContentView(revAddress: "1A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P7Q8R9S0T")
        .preferredColorScheme(.light)
}
