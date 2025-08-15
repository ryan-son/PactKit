//
//  MockKeyStore.swift
//  PactKit
//
//  Created by Geonhee on 8/12/25.
//

import Foundation
@testable import PactKitCore

/// An in-memory mock implementation of `SecureKeyStoring` for testing purposes.
final class MockKeyStore: SecureKeyStoring {
  var storage: [String: Data] = [:]

  func save(key: Data, for identifier: String) throws {
    storage[identifier] = key
  }

  func load(for identifier: String) throws -> Data? {
    return storage[identifier]
  }

  func delete(for identifier: String) throws {
    storage[identifier] = nil
  }
}
