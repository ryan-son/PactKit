//
//  HandshakeRequest.swift
//  PactKit
//
//  Created by Geonhee on 8/12/25.
//

import Foundation

extension Pact {
  /// A structure representing the initial handshake message sent from a Counterpart to the Host.
  public struct HandshakeRequest: Codable {
    /// The ephemeral public key of the counterpart for this session.
    public let ephemeralPublicKey: Data

    public init(ephemeralPublicKey: Data) {
      self.ephemeralPublicKey = ephemeralPublicKey
    }
  }

  /// A structure representing the response message sent from the Host to the Counterpart.
  public struct HandshakeResponse: Codable {
    /// The ephemeral public key of the Host for this session.
    public let ephemeralPublicKey: Data
    /// The Host's signature over the handshake transcript to prove its identity.
    public let signature: Data

    public init(ephemeralPublicKey: Data, signature: Data) {
      self.ephemeralPublicKey = ephemeralPublicKey
      self.signature = signature
    }
  }
}
