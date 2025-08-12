//
//  PactHostChannelTests.swift
//  PactKit
//
//  Created by Geonhee on 8/12/25.
//

import CryptoKit
import Testing

@testable import PactKit

@Suite("Pact.Host Channel Establishment Tests")
struct PactHostChannelTests {

  var host: Pact.Host!

  init() throws {
    let mockKeyStore = MockKeyStore()
    self.host = try Pact.Host(identityStore: mockKeyStore)
  }

  @Test(
    "A secure channel can be successfully established with a valid counterpart",
    .tags(.integration, .channel, .happyPath)
  )
  func successfulChannelEstablishment() throws {
    // Simulate a counterpart by creating its own ephemeral key pair.
    let counterpartEphemeralPrivateKey = P256.KeyAgreement.PrivateKey()
    let counterpartEphemeralPublicKey = counterpartEphemeralPrivateKey.publicKey
    let handshakeRequest = Pact.HandshakeRequest(ephemeralPublicKey: counterpartEphemeralPublicKey.rawRepresentation)

    // The Host processes the request and establishes its side of the channel.
    let (hostChannel, handshakeResponse) = try host.establishChannel(with: handshakeRequest)

    // The counterpart validates the response and establishes its side.

    // 1. The counterpart computes the same shared secret.
    let hostEphemeralPublicKey = try P256.KeyAgreement.PublicKey(rawRepresentation: handshakeResponse.ephemeralPublicKey)
    let counterpartSharedSecret = try counterpartEphemeralPrivateKey.sharedSecretFromKeyAgreement(with: hostEphemeralPublicKey)

    // 2. The counterpart derives the same session key using the identical HKDF parameters.
    let counterpartSessionKey = counterpartSharedSecret.hkdfDerivedSymmetricKey(
      using: SHA256.self,
      salt: "PactKit-Channel-Establishment-Salt".data(using: .utf8)!,
      sharedInfo: hostEphemeralPublicKey.rawRepresentation + counterpartEphemeralPublicKey.rawRepresentation,
      outputByteCount: 32
    )

    // 3. The counterpart verifies the signature using the Host's public identity key.
    let transcript = hostEphemeralPublicKey.rawRepresentation + counterpartEphemeralPublicKey.rawRepresentation
    let isSignatureValid = host.identity.publicKey.isValidSignature(handshakeResponse.signature, for: transcript)
    #expect(isSignatureValid, "The signature from the Host must be valid.")

    // 4. Finally, test end-to-end encryption to prove the session keys match.
    let originalMessage = "Hello, PactKit! This is a secure channel."
    let encryptedData = try hostChannel.encrypt(message: originalMessage)

    // Create a temporary channel for the counterpart with its derived key.
    let counterpartChannel = Pact.Channel(sessionKey: counterpartSessionKey)
    let decryptedMessage = try counterpartChannel.decrypt(encryptedData: encryptedData)

    #expect(decryptedMessage == originalMessage, "The decrypted message must match the original.")
  }
}
