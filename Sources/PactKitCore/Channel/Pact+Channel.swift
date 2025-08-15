//
//  Pact+Channel.swift
//  PactKit
//
//  Created by Geonhee on 8/12/25.
//

import CryptoKit
import Foundation

extension Pact {
  /// A secure communication channel established after a successful handshake.
  /// This object holds the symmetric session key and handles encryption and decryption for a single session.
  public final class Channel {
    private let sessionKey: SymmetricKey

    /// It is not recommended to initialize this object directly.
    /// Use `Pact.Host.establishChannel()` to create a secure channel.
    internal init(sessionKey: SymmetricKey) {
      self.sessionKey = sessionKey
    }

    /// Encrypts a plaintext string using AES-GCM with the session key.
    /// - Parameter message: The string to encrypt.
    /// - Returns: The combined data containing the nonce, ciphertext, and authentication tag.
    public func encrypt(message: String) throws -> Data {
      guard let messageData = message.data(using: .utf8) else {
        throw Pact.Error.codingError(.stringToDataConversionFailed)
      }
      let sealedBox = try AES.GCM.seal(messageData, using: self.sessionKey)
      guard let combinedData = sealedBox.combined else {
        throw Pact.Error.cryptoError(.encryptionFailed(reason: "Failed to get combined data from sealed box."))
      }
      return combinedData
    }

    /// Decrypts data encrypted with the session key.
    /// - Parameter encryptedData: The combined data from the counterpart.
    /// - Returns: The original plaintext string.
    public func decrypt(encryptedData: Data) throws -> String {
      guard let sealedBox = try? AES.GCM.SealedBox(combined: encryptedData) else {
        throw Pact.Error.cryptoError(.decryptionFailed(reason: "Invalid sealed box data."))
      }
      let decryptedData = try AES.GCM.open(sealedBox, using: self.sessionKey)

      guard let message = String(data: decryptedData, encoding: .utf8) else {
        throw Pact.Error.codingError(.dataToStringConversionFailed)
      }
      return message
    }
  }
}
