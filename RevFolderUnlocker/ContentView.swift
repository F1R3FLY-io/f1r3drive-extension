//
//  ContentView.swift
//  RevFolderUnlockerApp
//
//  Created by Andrii Stefaniv on 27.05.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var privateKey: String = ""
    var revAddress: String

    var body: some View {
        VStack(spacing: 16) {
            Image("f1r3fly_icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(spacing: 8) {
                Text("Folder Unlock Required")
                    .font(.headline)
                
                Text("Enter your private key to unlock the folder")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                HStack {
                    Image(systemName: "key.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text("Rev Address")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(revAddress)
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .onTapGesture {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(revAddress, forType: .string)
                    }
                    .help("Tap to copy address")
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("Private Key")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                SecureField("Enter your private key...", text: $privateKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            HStack(spacing: 12) {
                Button("Cancel") {
                    NSApplication.shared.keyWindow?.close()
                }
                .keyboardShortcut(.cancelAction)

                Button("Unlock Folder") {
                    print("Unlocking with key: \(privateKey)")
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 350, height: 280)
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
    ContentView(revAddress: "SampleRevAddress")
}
