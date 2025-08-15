//
//  Pact+Host.swift
//  PactKit
//
//  Created by Geonhee on 8/12/25.
//

import CryptoKit
import Foundation

extension Pact {
  /// The central object that represents the trusted party (the "Host") in a secure communication setup.
  /// It manages the Host's identity and is responsible for establishing secure channels.
  public final class Host {

    /// The permanent identity of this Host, used for signing operations.
    private let identity: Identity

    /// The public part of the identity key, which can be shared with counterparts for signature verification.
    public var identityPublicKey: Curve25519.Signing.PublicKey {
      identity.publicKey
    }

    /// Initializes a new Host instance.
    ///
    /// This initializer will attempt to load an existing identity from the provided key store.
    /// If no identity is found, a new one will be created and saved automatically.
    /// - Parameter identityStore: The secure store to use for persisting the Host's identity key.
    ///   Defaults to a standard `KeychainStore`.
    public init(identityStore: any SecureKeyStoring = KeychainStore()) throws {
      self.identity = try Identity(keyStore: identityStore)
    }

    /// Signs the given data with the Host's permanent identity private key.
    /// - Parameter data: The data to be signed.
    /// - Returns: The signature for the given data.
    public func signature(for data: Data) throws -> Data {
      return try identity.privateKey.signature(for: data)
    }
  }
}
