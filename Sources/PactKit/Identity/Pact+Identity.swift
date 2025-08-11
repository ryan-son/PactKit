//
//  Identity.swift
//  PactKit
//
//  Created by Geonhee on 8/12/25.
//

import Foundation
import CryptoKit

extension Pact {
  /// Represents the permanent identity of the Host.
  public final class Identity {
    private let keyStore: any SecureKeyStoring
    private let identityKeyIdentifier = "pactkit.host.identity.privatekey"

    public let privateKey: Curve25519.Signing.PrivateKey

    public var publicKey: Curve25519.Signing.PublicKey {
      privateKey.publicKey
    }

    public init(keyStore: any SecureKeyStoring = KeychainStore()) throws {
      self.keyStore = keyStore

      let identityKeyIdentifier = "pactkit.host.identity.privatekey"

      if let loadedKeyData = try self.keyStore.load(for: identityKeyIdentifier) {
        do {
          self.privateKey = try Curve25519.Signing.PrivateKey(rawRepresentation: loadedKeyData)
        } catch {
          throw Pact.Error.cryptoError(.keyCreationFromDataFailed)
        }
      } else {
        let newPrivateKey = Curve25519.Signing.PrivateKey()
        try self.keyStore.save(key: newPrivateKey.rawRepresentation, for: identityKeyIdentifier)
        self.privateKey = newPrivateKey
      }
    }
  }
}
