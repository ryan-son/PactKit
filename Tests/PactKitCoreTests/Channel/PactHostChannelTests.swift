//
//  PactHostChannelTests.swift
//  PactKit
//
//  Created by Geonhee on 8/12/25.
//

import Testing
import CryptoKit
import Foundation

@testable import PactKitCore

@Suite("Pact.Host Channel Establishment Tests")
struct PactHostChannelTests {

  var host: Pact.Host!
  let converter = P256PublicKeyConverter()

  init() throws {
    let mockKeyStore = MockKeyStore()
    self.host = try Pact.Host(identityStore: mockKeyStore)
  }

  @Test(
    "Establishes a symmetric channel and enables E2E encryption (prefixed key)",
    .tags(.integration, .channel, .symmetric)
  )
  func channelEstablishmentWithPrefix() throws {
    // Arrange: Simulate a counterpart with its own Host instance and a prefixed key.
    // A real counterpart would be on another device, but for testing, we can simulate it with another Host.
    let counterpartPrivateKey = P256.KeyAgreement.PrivateKey()
    var counterpartKeyForExport = Data([0x04])
    counterpartKeyForExport.append(counterpartPrivateKey.publicKey.rawRepresentation)

    // Act
    let (hostChannel, handshakeResponse) = try host.establishChannel(with: counterpartKeyForExport)

    // Assert: The response key format should be symmetric.
    #expect(handshakeResponse.ephemeralPublicKey.count == 65)

    // Act (Counterpart side): The counterpart uses the response to establish its own channel.
    // For this test, we simulate this by calling a hypothetical `counterpart.establishChannel`
    // or by manually performing the final steps. Let's create the counterpart's channel manually.
    let (counterpartChannel, _) = try createCounterpartChannel(
      privateKey: counterpartPrivateKey,
      hostResponse: handshakeResponse,
      hostIdentityPublicKey: host.identityPublicKey
    )

    // Assert: The two channels can communicate.
    try assertCommunication(between: hostChannel, and: counterpartChannel)
  }

  @Test(
    "Establishes a symmetric channel and enables E2E encryption (raw key)",
    .tags(.integration, .channel, .symmetric)
  )
  func channelEstablishmentWithoutPrefix() throws {
    // Arrange: Simulate a counterpart sending a raw 64-byte key.
    let counterpartPrivateKey = P256.KeyAgreement.PrivateKey()
    let counterpartKeyForExport = counterpartPrivateKey.publicKey.rawRepresentation

    // Act
    let (hostChannel, handshakeResponse) = try host.establishChannel(with: counterpartKeyForExport)

    // Assert: The response key format should be symmetric.
    #expect(handshakeResponse.ephemeralPublicKey.count == 64)

    let (counterpartChannel, _) = try createCounterpartChannel(
      privateKey: counterpartPrivateKey,
      hostResponse: handshakeResponse,
      hostIdentityPublicKey: host.identityPublicKey
    )

    try assertCommunication(between: hostChannel, and: counterpartChannel)
  }

  // MARK: - Test Helpers

  /// Simulates the final steps a counterpart would take to create its own channel after receiving a response.
  private func createCounterpartChannel(
    privateKey: P256.KeyAgreement.PrivateKey,
    hostResponse: Pact.HandshakeResponse,
    hostIdentityPublicKey: Curve25519.Signing.PublicKey
  ) throws -> (channel: Pact.Channel, transcript: Data) {
    let hostKeyForImport = try converter.formatForCryptoKit(from: hostResponse.ephemeralPublicKey)
    let hostEphemeralPublicKey = try P256.KeyAgreement.PublicKey(rawRepresentation: hostKeyForImport)

    let counterpartKeyForTranscript = privateKey.publicKey.rawRepresentation

    let transcript = hostEphemeralPublicKey.rawRepresentation + counterpartKeyForTranscript

    let isSignatureValid = hostIdentityPublicKey.isValidSignature(hostResponse.signature, for: transcript)
    #expect(isSignatureValid, "Signature from the Host must be valid.")

    let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: hostEphemeralPublicKey)
    let sessionKey = sharedSecret.hkdfDerivedSymmetricKey(
      using: SHA256.self,
      salt: "PactKit-Channel-Establishment-Salt".data(using: .utf8)!,
      sharedInfo: transcript,
      outputByteCount: 32
    )

    return (Pact.Channel(sessionKey: sessionKey), transcript)
  }

  /// Asserts that two channels can successfully encrypt and decrypt a message.
  private func assertCommunication(between channelA: Pact.Channel, and channelB: Pact.Channel) throws {
    let originalMessage = "Hello, PactKit! This is a secure channel."

    // A -> B
    let encryptedFromA = try channelA.encrypt(message: originalMessage)
    let decryptedByB = try channelB.decrypt(encryptedData: encryptedFromA)
    #expect(decryptedByB == originalMessage)

    // B -> A
    let encryptedFromB = try channelB.encrypt(message: originalMessage)
    let decryptedByA = try channelA.decrypt(encryptedData: encryptedFromB)
    #expect(decryptedByA == originalMessage)
  }
}
