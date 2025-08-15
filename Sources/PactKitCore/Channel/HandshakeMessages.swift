//
//  HandshakeMessages.swift
//  PactKit
//
//  Created by Geonhee on 8/12/25.
//

import Foundation

extension Pact {
  /// A structure representing the initial handshake message sent from a Counterpart to the Host.
  public struct HandshakeRequest: Codable {
    /// The ephemeral public key of the counterpart for this session.
    ///
    /// This key is used for the ECDH key agreement. The format can be either 64 bytes (raw) or 65 bytes (with an uncompressed prefix).
    public let ephemeralPublicKey: Data

    public init(ephemeralPublicKey: Data) {
      self.ephemeralPublicKey = ephemeralPublicKey
    }
  }

  /// A structure representing the response message sent from the Host to the Counterpart to complete the handshake.
  public struct HandshakeResponse: Codable {
    /// The ephemeral public key of the Host for this session.
    ///
    /// The format of this key (64 or 65 bytes) will match the format of the key received in the `HandshakeRequest`.
    public let ephemeralPublicKey: Data

    /// The Host's signature over the handshake transcript.
    ///
    /// This signature is created with the Host's permanent identity key and is used by the counterpart to verify the Host's identity.
    public let signature: Data

    public init(ephemeralPublicKey: Data, signature: Data) {
      self.ephemeralPublicKey = ephemeralPublicKey
      self.signature = signature
    }
  }
}
