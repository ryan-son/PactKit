//
//  P256PublicKeyConverter.swift
//  PactKit
//
//  Created by Geonhee on 8/15/25.
//

import CryptoKit
import Foundation

/// A utility to perform cryptographic operations with P-256 public keys,
/// handling interoperability between CryptoKit and other formats (e.g., SubtleCrypto).
public struct P256PublicKeyConverter {

    public static let uncompressedKeyPrefix: UInt8 = 0x04
    public static let keySizeWithoutPrefix = 64

    /// Converts raw key data (potentially with a prefix) into the 64-byte format required by CryptoKit.
    public func formatForCryptoKit(from rawData: Data) throws -> Data {
        var keyData = rawData
        if keyData.first == Self.uncompressedKeyPrefix {
            keyData = keyData.dropFirst()
        }
        guard keyData.count == Self.keySizeWithoutPrefix else {
            throw Pact.Error.cryptoError(.invalidKeySize(expected: Self.keySizeWithoutPrefix, actual: keyData.count))
        }
        return keyData
    }

    /// Formats a 64-byte CryptoKit key for export, respecting the original format of a counterpart's key.
    public func formatForExport(from cryptoKitData: Data, basedOn originalData: Data) -> Data {
        let counterpartHadPrefix = (originalData.first == Self.uncompressedKeyPrefix && originalData.count == Self.keySizeWithoutPrefix + 1)

        guard cryptoKitData.count == Self.keySizeWithoutPrefix else {
            return cryptoKitData // Should not happen with valid CryptoKit data.
        }

        if counterpartHadPrefix {
            var exportData = Data([Self.uncompressedKeyPrefix])
            exportData.append(cryptoKitData)
            return exportData
        } else {
            return cryptoKitData
        }
    }

    /// Performs a given operation atomically, handling all key format conversions.
    public func perform<T>(
        with counterpartKeyData: Data,
        operation: (_ cryptoKitKey: P256.KeyAgreement.PublicKey) throws -> (responseKey: P256.KeyAgreement.PublicKey, result: T)
    ) throws -> CryptoOperationResult<T> {

        let keyForImport = try formatForCryptoKit(from: counterpartKeyData)
        let counterpartPublicKey = try P256.KeyAgreement.PublicKey(rawRepresentation: keyForImport)

        let (responseKey, operationResult) = try operation(counterpartPublicKey)

        let responseKeyData = formatForExport(from: responseKey.rawRepresentation, basedOn: counterpartKeyData)

        return CryptoOperationResult(
            responseKeyData: responseKeyData,
            result: operationResult
        )
    }
}
