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
    /// An error related to data encoding or decoding.
    case codingError(CodingFailure)

    public var errorDescription: String? {
      switch self {
      case .keychainError(let failure):
        return "Keychain Operation Failed: \(failure.localizedDescription)"
      case .cryptoError(let failure):
        return "Cryptographic Operation Failed: \(failure.localizedDescription)"
      case .codingError(let failure):
        return "Data Coding Failed: \(failure.localizedDescription)"
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
    case encryptionFailed(reason: String)
    case decryptionFailed(reason: String)

    public var errorDescription: String? {
      switch self {
      case .keyCreationFromDataFailed:
        return "Failed to create a cryptographic key from the provided raw data."
      case .encryptionFailed(let reason):
        return "Encryption failed. Reason: \(reason)"
      case .decryptionFailed(let reason):
        return "Decryption failed. This may be due to data corruption, tampering, or an incorrect key. Reason: \(reason)"
      }
    }
  }

  /// Specifies the reason for a data coding failure.
  public enum CodingFailure: Swift.Error, LocalizedError, Equatable {
    case stringToDataConversionFailed
    case dataToStringConversionFailed

    public var errorDescription: String? {
      switch self {
      case .stringToDataConversionFailed:
        return "Failed to convert a String to UTF-8 Data."
      case .dataToStringConversionFailed:
        return "Failed to convert Data to a UTF-8 String."
      }
    }
  }
}
