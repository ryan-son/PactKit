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
  ///
  /// The `Host` class is the main entry point for the library. It encapsulates the host's permanent cryptographic identity
  /// and provides methods to establish secure, end-to-end encrypted channels with untrusted counterparts.
  ///
  /// ## Topics
  ///
  /// ### Initialization
  /// - ``init(identityStore:)``
  ///
  /// ### Identity
  /// - ``identityPublicKey``
  ///
  /// ### Channel Establishment
  /// - ``establishChannel(with:)``
  public final class Host {

    /// The permanent identity of this Host, used for signing operations.
    private let identity: Identity

    /// The public key of this Host's permanent identity, which can be shared with counterparts for signature verification.
    ///
    /// This key is the root of trust for any counterpart communicating with this host.
    public var identityPublicKey: Curve25519.Signing.PublicKey {
      identity.publicKey
    }

    /// Initializes a new Host instance.
    ///
    /// This initializer will attempt to load an existing identity from the provided key store.
    /// If no identity is found, a new one will be created and saved automatically to the store.
    /// It is recommended to initialize this object on a background thread to avoid blocking the main thread,
    /// as keychain access can be slow.
    ///
    /// - Parameter identityStore: The secure store to use for persisting the Host's identity key.
    ///   Defaults to a standard `KeychainStore`.
    /// - Throws: `Pact.Error` if keychain operations fail or if loaded key data is corrupted.
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
