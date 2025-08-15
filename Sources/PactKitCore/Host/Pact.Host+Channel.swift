//
//  Host+Channel.swift
//  PactKit
//
//  Created by Geonhee on 8/12/25.
//

import CryptoKit
import Foundation

import Foundation
import CryptoKit

extension Pact.Host {
  /// Establishes a new secure channel with a counterpart using their ephemeral public key.
  ///
  /// This method performs the complete authenticated ECDH key exchange protocol (P-256 for key agreement + Ed25519 for signing).
  /// It handles key format interoperability between CryptoKit and other crypto libraries (like JavaScript's SubtleCrypto).
  ///
  /// - Parameter counterpartEphemeralPublicKeyData: The raw ephemeral public key received from the counterpart. This data may include a prefix (e.g., `0x04`).
  /// - Returns: A tuple containing the newly established `Pact.Channel` for secure communication and the `HandshakeResponse` to be sent back to the counterpart.
  public func establishChannel(
    with counterpartEphemeralPublicKeyData: Data
  ) throws -> (channel: Pact.Channel, response: Pact.HandshakeResponse) {
    let converter = P256PublicKeyConverter()

    let operationResult: CryptoOperationResult<(channel: Pact.Channel, signature: Data)> = try converter.perform(with: counterpartEphemeralPublicKeyData) { counterpartPublicKey in

      let hostEphemeralPrivateKey = P256.KeyAgreement.PrivateKey()
      let hostEphemeralPublicKey = hostEphemeralPrivateKey.publicKey

      let sharedSecret = try hostEphemeralPrivateKey.sharedSecretFromKeyAgreement(with: counterpartPublicKey)

      let transcript = hostEphemeralPublicKey.rawRepresentation + counterpartPublicKey.rawRepresentation

      let sessionKey = sharedSecret.hkdfDerivedSymmetricKey(
        using: SHA256.self,
        salt: "PactKit-Channel-Establishment-Salt".data(using: .utf8)!,
        sharedInfo: transcript,
        outputByteCount: 32
      )

      let signature = try self.signature(for: transcript)
      let channel = Pact.Channel(sessionKey: sessionKey)
      return (responseKey: hostEphemeralPublicKey, result: (channel, signature))
    }

    let responseKeyData = operationResult.responseKeyData
    let (channel, signature) = operationResult.result

    let response = Pact.HandshakeResponse(
        ephemeralPublicKey: responseKeyData,
        signature: signature
    )

    return (channel, response)
  }
}
