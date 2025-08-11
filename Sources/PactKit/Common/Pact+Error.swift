//
//  Pact+Error.swift
//  PactKit
//
//  Created by Geonhee on 8/12/25.
//

import Foundation

extension Pact {
  /// Describes the errors that can occur within the PactKit framework.
  public enum Error: Swift.Error, LocalizedError, Equatable {
    /// An error related to Keychain operations.
    case keychainError(KeychainFailure)
    
    /// An error related to cryptographic operations.
    case cryptoError(CryptoFailure)
    
    public var errorDescription: String? {
      switch self {
      case .keychainError(let failure):
        return "Keychain Operation Failed: \(failure.localizedDescription)"
      case .cryptoError(let failure):
        return "Cryptographic Operation Failed: \(failure.localizedDescription)"
      }
    }
  }
}

extension Pact.Error {
  /// Specifies the reason for a Keychain operation failure.
  public enum KeychainFailure: Swift.Error, LocalizedError, Equatable {
    case saveFailed(status: OSStatus)
    case loadFailed(status: OSStatus)
    case deleteFailed(status: OSStatus)
    case invalidData
    
    public var errorDescription: String? {
      switch self {
      case .saveFailed(let status):
        return "Could not save item to Keychain. OSStatus: \(status)"
      case .loadFailed(let status):
        return "Could not load item from Keychain. OSStatus: \(status)"
      case .deleteFailed(let status):
        return "Could not delete item from Keychain. OSStatus: \(status)"
      case .invalidData:
        return "Data from Keychain was in an unexpected format."
      }
    }
  }
  
  /// Specifies the reason for a cryptographic operation failure.
  public enum CryptoFailure: Swift.Error, LocalizedError, Equatable {
    case keyCreationFromDataFailed
    
    public var errorDescription: String? {
      switch self {
      case .keyCreationFromDataFailed:
        return "Failed to create a cryptographic key from the provided raw data."
      }
    }
  }
}
