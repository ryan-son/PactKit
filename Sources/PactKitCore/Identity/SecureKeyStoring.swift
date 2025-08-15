//
//  SecureKeyStoring.swift
//  PactKit
//
//  Created by Geonhee on 8/12/25.
//

import Foundation

/// An interface for securely storing, loading, and deleting key data.
public protocol SecureKeyStoring {
  func save(key: Data, for identifier: String) throws
  func load(for identifier: String) throws -> Data?
  func delete(for identifier: String) throws
}
