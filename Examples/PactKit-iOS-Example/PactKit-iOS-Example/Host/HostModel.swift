//
//  HostModel.swift
//  PactKit-iOS-Example
//
//  Created by Geonhee on 8/13/25.
//

import Combine
import Foundation
import PactKit

@MainActor
final class HostModel: ObservableObject {

  @Published var statusMessage: String = "Welcome to PactKit!"
  @Published var isChannelEstablished: Bool = false
  @Published var receivedMessages: [String] = []

  private let host: Pact.Host
  private var channel: Pact.Channel?

  let messageToJS = PassthroughSubject<String, Never>()

  init() {
    do {
      self.host = try Pact.Host()
      self.statusMessage = "Host initialized. Waiting for handshake."
    } catch {
      self.host = try! Pact.Host() // Fallback for preview, handle error properly in real apps
      self.statusMessage = "Error initializing host: \(error.localizedDescription)"
    }
  }

  func getIdentityKeyForInjection() -> String {
    return host.identity.publicKey.rawRepresentation.base64EncodedString()
  }

  func handleMessageFromJS(_ messageBody: Any) {
    guard
      let jsonString = messageBody as? String,
      let data = jsonString.data(using: .utf8)
    else {
      statusMessage = "Error: Received invalid message format from JS."
      return
    }

    do {
      let incomingMessage = try Pact.base64JSONDecoder.decode(IncomingMessage.self, from: data)

      switch incomingMessage {
      case .handshakeRequest(let request):
        handleHandshake(request: request)
      case .encryptedMessage(let encryptedMessage):
        handleEncryptedMessage(encryptedMessage)
      }
    } catch {
      statusMessage = "Error decoding message: \(error.localizedDescription)"
    }
  }

  private func sendMessageToJS(_ message: OutgoingMessage) {
    do {
      let jsonData = try Pact.base64JSONEncoder.encode(message)
      let jsonString = String(data: jsonData, encoding: .utf8)!

      let escapedString = jsonString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
      messageToJS.send("window.handleNativeResponse(decodeURIComponent('\(escapedString)'));")

    } catch {
      statusMessage = "Error encoding outgoing message: \(error.localizedDescription)"
    }
  }

  private func handleHandshake(request: Pact.HandshakeRequest) {
    statusMessage = "Received handshake request, establishing channel..."
    do {
      let (newChannel, response) = try host.establishChannel(with: request)
      self.channel = newChannel
      self.isChannelEstablished = true
      statusMessage = "✅ Secure channel established!"

      sendMessageToJS(.handshakeResponse(response))
    } catch {
      statusMessage = "Error during handshake: \(error.localizedDescription)"
    }
  }

  private func handleEncryptedMessage(_ message: EncryptedMessage) {
    guard let channel = self.channel else {
      statusMessage = "Error: Received a message but channel is not established."
      return
    }

    do {
      let decryptedText = try channel.decrypt(encryptedData: message.ciphertext)
      statusMessage = "⬇️ Decrypted message: \"\(decryptedText)\""
    } catch {
      statusMessage = "Error decrypting message: \(error.localizedDescription)"
    }
  }

  public func sendEncryptedMessage(plaintext: String) {
    guard let channel = self.channel else {
      statusMessage = "Error: Channel is not established."
      return
    }

    do {
      let encryptedData = try channel.encrypt(message: plaintext)
      let encryptedMessage = EncryptedMessage(ciphertext: encryptedData)

      sendMessageToJS(.encryptedMessage(encryptedMessage))
      statusMessage = "⬆️ Sent encrypted message."
    } catch {
      statusMessage = "Error sending message: \(error.localizedDescription)"
    }
  }
}
