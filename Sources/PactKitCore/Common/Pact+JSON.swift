//
//  Pact+JSON.swift
//  PactKit
//
//  Created by Geonhee on 8/13/25.
//

import Foundation

public extension Pact {
  /// A pre-configured JSON decoder that uses the Base64 strategy for Data.
  static var base64JSONDecoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dataDecodingStrategy = .base64
    return decoder
  }

  /// A pre-configured JSON encoder that uses the Base64 strategy for Data.
  static var base64JSONEncoder: JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dataEncodingStrategy = .base64
    return encoder
  }
}
