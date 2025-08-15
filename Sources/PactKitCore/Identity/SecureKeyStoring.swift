//
//  SecureKeyStoring.swift
//  PactKit
//
//  Created by Geonhee on 8/12/25.
//

import Foundation

/// An interface for securely storing, loading, and deleting key data.
///
/// This protocol abstracts the underlying storage mechanism (e.g., Keychain, UserDefaults, in-memory)
/// to allow for dependency injection and improved testability.
public protocol SecureKeyStoring {
  /// Saves a key to the secure store. If a key with the same identifier already exists, it should be overwritten.
  /// - Parameters:
  ///   - key: The key data to save.
  ///   - identifier: A unique identifier for the key.
  /// - Throws: An error if the save operation fails.
  func save(key: Data, for identifier: String) throws

  /// Loads a key from the secure store.
  /// - Parameter identifier: The unique identifier for the key.
  /// - Returns: The key data, or `nil` if no key is found for the given identifier.
  /// - Throws: An error if the load operation fails for reasons other than the item not being found.
  func load(for identifier: String) throws -> Data?

  /// Deletes a key from the secure store.
  /// - Parameter identifier: The unique identifier for the key to delete.
  /// - Throws: An error if the delete operation fails.
  func delete(for identifier: String) throws
}
