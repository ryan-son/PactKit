//
//  Pact+Host.swift
//  PactKit
//
//  Created by Geonhee on 8/12/25.
//

import Foundation

extension Pact {
  /// The central object that represents the trusted party (the "Host") in a secure communication setup.
  /// It manages the Host's identity and is responsible for establishing secure channels.
  public final class Host {

    /// The permanent identity of this Host, used for signing operations.
    public let identity: Identity

    /// Initializes a new Host instance.
    ///
    /// This initializer will attempt to load an existing identity from the provided key store.
    /// If no identity is found, a new one will be created and saved automatically.
    /// - Parameter identityStore: The secure store to use for persisting the Host's identity key.
    ///   Defaults to a standard `KeychainStore`.
    public init(identityStore: any SecureKeyStoring = KeychainStore()) throws {
      self.identity = try Identity(keyStore: identityStore)
    }
  }
}
