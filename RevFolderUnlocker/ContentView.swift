//
//  ContentView.swift
//  RevFolderUnlocker
//
//  Created by Andrii Stefaniv on 27.05.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var privateKey: String = ""
    var revAddress: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Private Key for \(revAddress)")
                .font(.headline)

            TextField("Private Key", text: $privateKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            HStack {
                Button("Cancel") {
                    NSApplication.shared.keyWindow?.close()
                }
                .keyboardShortcut(.cancelAction)

                Button("Unlock") {
                    print("Unlocking with key: \(privateKey)")
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 300, height: 200)
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
