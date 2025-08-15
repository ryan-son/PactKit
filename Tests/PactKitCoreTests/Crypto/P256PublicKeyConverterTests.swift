//
//  P256PublicKeyConverterTests.swift
//  PactKit
//
//  Created by Geonhee on 8/15/25.
//

import Foundation
import Testing

@testable import PactKitCore

@Suite("P256PublicKeyConverter Tests")
struct P256PublicKeyConverterTests {

  let converter = P256PublicKeyConverter()

  static let raw64ByteKey = Data(repeating: 0x01, count: 64)
  static let raw65ByteKeyWithPrefix = Data([0x04]) + Data(repeating: 0x01, count: 64)

  @Test(
    "formatForCryptoKit should strip the 0x04 prefix from a 65-byte key",
    .tags(.unit, .crypto, .happyPath)
  )
  func formatForCryptoKitStripsPrefix() throws {
    let result = try converter.formatForCryptoKit(from: Self.raw65ByteKeyWithPrefix)

    // Assert
    #expect(result.count == 64)
    #expect(result == Self.raw64ByteKey)
  }

  @Test(
    "formatForCryptoKit should pass through a 64-byte key unmodified",
    .tags(.unit, .crypto, .happyPath)
  )
  func formatForCryptoKitAccepts64ByteKey() throws {
    let result = try converter.formatForCryptoKit(from: Self.raw64ByteKey)

    // Assert
    #expect(result.count == 64)
    #expect(result == Self.raw64ByteKey)
  }

  @Test(
    "formatForCryptoKit should throw an error for keys of invalid size",
    .tags(.unit, .crypto, .errorHandling)
  )
  func formatForCryptoKitThrowsErrorForInvalidSize() throws {
    // Arrange
    let invalidKey = Data(repeating: 0x01, count: 63)

    // Act & Assert
    #expect(throws: Pact.Error.self) {
      _ = try converter.formatForCryptoKit(from: invalidKey)
    }
  }

  @Test(
    "formatForExport should prepend prefix when original data had a prefix",
    .tags(.unit, .crypto, .symmetric)
  )
  func formatForExportIsSymmetricWithPrefix() {
    // Arrange
    let originalDataFromCounterpart = Self.raw65ByteKeyWithPrefix
    let keyToSendBack = Self.raw64ByteKey

    // Act: Call the method with the new signature.
    let result = converter.formatForExport(
      from: keyToSendBack,
      basedOn: originalDataFromCounterpart
    )

    // Assert: The result should be 65 bytes, matching the original format.
    #expect(result.count == 65)
    #expect(result == Self.raw65ByteKeyWithPrefix)
  }

  @Test(
    "formatForExport should NOT prepend prefix when original data was raw",
    .tags(.unit, .crypto, .symmetric)
  )
  func formatForExportIsSymmetricWithoutPrefix() {
    // Arrange
    let originalDataFromCounterpart = Self.raw64ByteKey
    let keyToSendBack = Self.raw64ByteKey

    // Act
    let result = converter.formatForExport(
      from: keyToSendBack,
      basedOn: originalDataFromCounterpart
    )

    // Assert: The result should be 64 bytes, matching the original format.
    #expect(result.count == 64)
    #expect(result == Self.raw64ByteKey)
  }
}
