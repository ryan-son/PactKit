//
//  ContentView.swift
//  PactKit-iOS-Example
//
//  Created by Geonhee on 8/13/25.
//

import SwiftUI

struct HostView: View {
  @StateObject private var model = HostModel()
  @State private var messageToSend: String = ""

  var body: some View {
    VStack(spacing: 16) {
      Text("PactKit SwiftUI Demo")
        .font(.largeTitle)
        .fontWeight(.bold)

      HStack {
        TextField("Enter a secret message", text: $messageToSend)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .disabled(!model.isChannelEstablished)

        Button("Send") {
          model.sendEncryptedMessage(plaintext: messageToSend)
          messageToSend = ""
        }
        .disabled(!model.isChannelEstablished)
      }

      // The WebView that hosts our counterpart
      WebView(
        url: URL(string: "http://localhost:8080")!,
        model: model
      )
      .border(Color.gray, width: 1)

      VStack {
        Text("Status")
          .font(.headline)

        Text(model.statusMessage)
          .font(.caption)
          .multilineTextAlignment(.center)
      }
      .padding()
      .background(Color(.secondarySystemBackground))
      .cornerRadius(8)
    }
    .padding()
  }
}

#Preview {
  HostView()
}
