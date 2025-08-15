//
//  CryptoOperationResult.swift
//  PactKit
//
//  Created by Geonhee on 8/15/25.
//

import Foundation

/// A structure that encapsulates the result of a cryptographic operation performed by `P256PublicKeyConverter`.
/// It contains the result of the operation itself, along with the response key formatted for the counterpart.
public struct CryptoOperationResult<T> {
  /// The public key data formatted to be sent back to the counterpart,
  /// matching the counterpart's original key format (prefixed or not).
  public let responseKeyData: Data

  /// The generic result payload from the cryptographic operation that was executed.
  public let result: T
}
