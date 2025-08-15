//
//  MessageModels.swift
//  PactKit-iOS-Example
//
//  Created by Geonhee on 8/13/25.
//

import Foundation
import PactKitCore

// MARK: - Payloads

/// A wrapper for an encrypted payload.
struct EncryptedMessage: Codable {
  let ciphertext: Data
}

// MARK: - Message Enums

/// Represents all possible messages sent from JavaScript to the Native Host.
enum IncomingMessage: Decodable {
  case handshakeRequest(Pact.HandshakeRequest)
  case encryptedMessage(EncryptedMessage)

  private enum CodingKeys: String, CodingKey {
    case type, payload
  }

  private enum MessageType: String, Decodable {
    case handshakeRequest, encryptedMessage
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(MessageType.self, forKey: .type)

    switch type {
    case .handshakeRequest:
      let payload = try container.decode(Pact.HandshakeRequest.self, forKey: .payload)
      self = .handshakeRequest(payload)
    case .encryptedMessage:
      let payload = try container.decode(EncryptedMessage.self, forKey: .payload)
      self = .encryptedMessage(payload)
    }
  }
}

/// Represents all possible messages sent from the Native Host to JavaScript.
enum OutgoingMessage: Encodable {
  case handshakeResponse(Pact.HandshakeResponse)
  case encryptedMessage(EncryptedMessage)

  private enum CodingKeys: String, CodingKey {
    case type, payload
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .handshakeResponse(let payload):
      try container.encode("handshakeResponse", forKey: .type)
      try container.encode(payload, forKey: .payload)
    case .encryptedMessage(let payload):
      try container.encode("encryptedMessage", forKey: .type)
      try container.encode(payload, forKey: .payload)
    }
  }
}
