//
//  Host+Channel.swift
//  PactKit
//
//  Created by Geonhee on 8/12/25.
//

import CryptoKit
import Foundation

extension Pact.Host {
  /// Establishes a new secure channel with a counterpart.
  /// This method performs the authenticated ECDH key exchange protocol (P-256 for key agreement + Ed25519 for signing).
  ///
  /// - Parameter handshakeRequest: The initial request from the counterpart, containing their ephemeral public key.
  /// - Returns: A tuple containing the newly created `Pact.Channel` for secure communication and a `HandshakeResponse` to be sent back to the counterpart.
  public func establishChannel(
    with handshakeRequest: Pact.HandshakeRequest
  ) throws -> (channel: Pact.Channel, response: Pact.HandshakeResponse) {
    let hostEphemeralPrivateKey = P256.KeyAgreement.PrivateKey()
    let hostEphemeralPublicKey = hostEphemeralPrivateKey.publicKey

    let counterpartEphemeralPublicKey = try P256.KeyAgreement.PublicKey(rawRepresentation: handshakeRequest.ephemeralPublicKey)

    let sharedSecret = try hostEphemeralPrivateKey.sharedSecretFromKeyAgreement(with: counterpartEphemeralPublicKey)

    let sessionKey = sharedSecret.hkdfDerivedSymmetricKey(
      using: SHA256.self,
      salt: "PactKit-Channel-Establishment-Salt".data(using: .utf8)!,
      sharedInfo: hostEphemeralPublicKey.rawRepresentation + counterpartEphemeralPublicKey.rawRepresentation,
      outputByteCount: 32 // 256 bits for AES-256-GCM.
    )

    let transcript = hostEphemeralPublicKey.rawRepresentation + counterpartEphemeralPublicKey.rawRepresentation
    let signature = try self.identity.privateKey.signature(for: transcript)

    let channel = Pact.Channel(sessionKey: sessionKey)
    let response = Pact.HandshakeResponse(
      ephemeralPublicKey: hostEphemeralPublicKey.rawRepresentation,
      signature: signature
    )

    return (channel, response)
  }
}
