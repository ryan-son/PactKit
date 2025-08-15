//
//  Pact+Error.swift
//  PactKit
//
//  Created by Geonhee on 8/12/25.
//

import Foundation

extension Pact {
  /// Describes the errors that can occur within the PactKit framework.
  ///
  /// This enum conforms to `LocalizedError` to provide user-friendly descriptions for each case.
  public enum Error: Swift.Error, LocalizedError, Equatable {
    /// An error related to Keychain operations. See `KeychainFailure` for specific reasons.
    case keychainError(KeychainFailure)
    /// An error related to cryptographic operations. See `CryptoFailure` for specific reasons.
    case cryptoError(CryptoFailure)
    /// An error related to data encoding or decoding. See `CodingFailure` for specific reasons.
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
    /// Failed to save an item to the Keychain. The associated `OSStatus` provides more details.
    case saveFailed(status: OSStatus)
    /// Failed to load an item from the Keychain. The associated `OSStatus` provides more details.
    case loadFailed(status: OSStatus)
    /// Failed to delete an item from the Keychain. The associated `OSStatus` provides more details.
    case deleteFailed(status: OSStatus)

    public var errorDescription: String? {
      switch self {
      case .saveFailed(let status):
        return "Could not save item to Keychain. OSStatus: \(status)"
      case .loadFailed(let status):
        return "Could not load item from Keychain. OSStatus: \(status)"
      case .deleteFailed(let status):
        return "Could not delete item from Keychain. OSStatus: \(status)"
      }
    }
  }

  /// Specifies the reason for a cryptographic operation failure.
  public enum CryptoFailure: Swift.Error, LocalizedError, Equatable {
    /// Failed to create a cryptographic key from the provided raw data.
    case keyCreationFromDataFailed
    /// The provided key data has an unexpected size.
    case invalidKeySize(expected: Int, actual: Int)
    /// An encryption operation failed.
    case encryptionFailed(reason: String)
    /// A decryption operation failed, potentially due to data corruption, tampering, or an incorrect key.
    case decryptionFailed(reason: String)

    public var errorDescription: String? {
      switch self {
      case .keyCreationFromDataFailed:
        return "Failed to create a cryptographic key from the provided raw data."
      case .invalidKeySize(let expected, let actual):
        return "Invalid key size. Expected \(expected) bytes, but received \(actual) bytes."
      case .encryptionFailed(let reason):
        return "Encryption failed. Reason: \(reason)"
      case .decryptionFailed(let reason):
        return "Decryption failed. Reason: \(reason)"
      }
    }
  }

  /// Specifies the reason for a data coding failure.
  public enum CodingFailure: Swift.Error, LocalizedError, Equatable {
    /// Failed to convert a `String` to UTF-8 `Data`.
    case stringToDataConversionFailed
    /// Failed to convert `Data` to a UTF-8 `String`.
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
