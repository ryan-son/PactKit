// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "PactKit",
  platforms: [
    .iOS(.v13),
    .macCatalyst(.v15),
    .macOS(.v10_15),
    .tvOS(.v15),
    .visionOS(.v1),
    .watchOS(.v8),
  ],
  products: [
    .library(
      name: "PactKitCore",
      targets: ["PactKitCore"]
    ),
  ],
  targets: [
    .target(
      name: "PactKitCore",
      dependencies: []
    ),
    .testTarget(
      name: "PactKitCoreTests",
      dependencies: ["PactKitCore"]
    ),
  ]
)

#if compiler(>=6)
for target in package.targets where target.type != .system && target.type != .test {
  target.swiftSettings = target.swiftSettings ?? []
  target.swiftSettings?.append(contentsOf: [
    .enableExperimentalFeature("StrictConcurrency"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InferSendableFromCaptures"),
  ])
}
#endif
