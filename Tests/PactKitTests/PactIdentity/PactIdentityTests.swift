//
//  PactIdentityTests.swift
//  PactKit
//
//  Created by Geonhee on 8/12/25.
//

import Testing
@testable import PactKit
import CryptoKit
import Foundation

@Suite("Pact.Identity Tests")
struct PactIdentityTests {

  @Test(
    "A new identity is created and saved when the key store is empty",
    .tags(.unit, .identity, .happyPath)
  )
  func creationWhenStoreIsEmpty() throws {
    let mockStore = MockKeyStore()
    #expect(try mockStore.load(for: "pactkit.host.identity.privatekey") == nil)

    let identity = try Pact.Identity(keyStore: mockStore)

    #expect(identity.privateKey.rawRepresentation.count > 0)
    let savedKey = try mockStore.load(for: "pactkit.host.identity.privatekey")
    #expect(savedKey != nil)
    #expect(savedKey == identity.privateKey.rawRepresentation)
  }

  @Test(
    "An existing identity key is loaded from the store",
    .tags(.unit, .identity, .happyPath)
  )
  func loadingExistingKey() throws {
    let mockStore = MockKeyStore()
    let existingKey = Curve25519.Signing.PrivateKey()
    try mockStore.save(key: existingKey.rawRepresentation, for: "pactkit.host.identity.privatekey")

    let identity = try Pact.Identity(keyStore: mockStore)

    #expect(identity.privateKey.rawRepresentation == existingKey.rawRepresentation)
  }

  @Test(
    "Throws a cryptoError when loaded data is invalid",
    .tags(.unit, .identity, .errorHandling)
  )
  func loadingInvalidKeyData() throws {
    let mockStore = MockKeyStore()
    let invalidData = "this is not a valid key".data(using: .utf8)!
    try mockStore.save(key: invalidData, for: "pactkit.host.identity.privatekey")

    #expect(throws: Pact.Error.self) {
      _ = try Pact.Identity(keyStore: mockStore)
    }
  }
}
