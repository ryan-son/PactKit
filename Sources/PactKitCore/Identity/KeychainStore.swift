//
//  KeychainStore.swift
//  PactKit
//
//  Created by Geonhee on 8/12/25.
//

import Foundation
import Security

/// A Keychain-based implementation of the `SecureKeyStoring` protocol.
public struct KeychainStore: SecureKeyStoring {
  private let service: String
  
  public init(service: String = Bundle.main.bundleIdentifier ?? "com.pactkit.default.service") {
    self.service = service
  }
  
  public func save(key: Data, for identifier: String) throws {
    try? delete(for: identifier)
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: identifier,
      kSecValueData as String: key,
      kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    ]
    let status = SecItemAdd(query as CFDictionary, nil)

    guard status == errSecSuccess else {
      throw Pact.Error.keychainError(.saveFailed(status: status))
    }
  }
  
  public func load(for identifier: String) throws -> Data? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: identifier,
      kSecReturnData as String: kCFBooleanTrue!,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]
    var dataTypeReference: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &dataTypeReference)

    if status == errSecSuccess {
      return dataTypeReference as? Data
    } else if status == errSecItemNotFound {
      return nil
    } else {
      throw Pact.Error.keychainError(.loadFailed(status: status))
    }
  }
  
  public func delete(for identifier: String) throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: identifier
    ]

    let status = SecItemDelete(query as CFDictionary)

    guard status == errSecSuccess || status == errSecItemNotFound else {
        throw Pact.Error.keychainError(.deleteFailed(status: status))
    }
  }
}
