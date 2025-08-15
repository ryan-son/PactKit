//
//  Testing+Tags.swift
//  PactKit
//
//  Created by Geonhee on 8/12/25.
//

import Testing

extension Tag {
  // MARK: Test Type
  @Tag static var unit: Self
  @Tag static var integration: Self
  @Tag static var e2e: Self

  // MARK: Feature Area
  @Tag static var channel: Self
  @Tag static var crypto: Self
  @Tag static var identity: Self
  @Tag static var keychain: Self
  @Tag static var symmetric: Self

  // MARK: Scenario
  @Tag static var happyPath: Self
  @Tag static var errorHandling: Self
  @Tag static var edgeCase: Self
}
