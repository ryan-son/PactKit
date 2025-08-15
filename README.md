# PactKit

🛡️ **Establish a circle of trust, anywhere.**

[![CI Status](https://github.com/ryan-son/PactKit/actions/workflows/ci.yml/badge.svg)](https://github.com/ryan-son/PactKit/actions)

A modern, Swift-native, end-to-end security framework for iOS. PactKit allows your app to act as a trusted host, creating secure, ephemeral communication channels with any counterpart.

---

## Philosophy

PactKit is built on the principle that a trusted native application (`Host`) can extend its "circle of trust" to an untrusted environment (`Counterpart`). It provides the cryptographic foundation to verify identity and ensure confidentiality in any local or hybrid communication scenario without relying on a central server.

---

## Features

- 🔒 **End-to-End Encryption:** All communication is secured using modern, vetted cryptography (AES-GCM).
- ✍️ **Authenticated Handshake:** Prevents Man-in-the-Middle (MitM) attacks using an authenticated key exchange protocol (ECDH P-256 + Ed25519 signatures).
- 🚀 **Forward Secrecy:** Each session uses ephemeral keys, ensuring that even if a key is compromised, past communications remain secure.
- 🧩 **Extensible & Testable:** Designed with protocols and dependency injection at its core for maximum flexibility and robustness.
- 🤝 **Transport Agnostic:** The core logic is completely independent of the communication layer, making it suitable for WebViews, Bluetooth (BLE), Wi-Fi Direct, and more.

---

## Installation

PactKit can be added to your project using Swift Package Manager.

### Using Xcode

1.  In Xcode, open your project and navigate to **File > Add Packages...**
2.  Paste the repository URL into the search bar at the top right:
    ```
    [https://github.com/ryan-son/PactKit.git](https://github.com/ryan-son/PactKit.git)
    ```
3.  For the **Dependency Rule**, select **Up to Next Major Version** and enter `0.1.0`.
4.  Click **Add Package**.
5.  Choose the `PactKitCore` library product and add it to your app's target.

### Using Package.swift

Add `PactKit` to your dependencies array in your `Package.swift` file:

```swift
dependencies: [
  .package(url: "[https://github.com/ryan-son/PactKit.git](https://github.com/ryan-son/PactKit.git)", from: "0.1.0")
]
````

Then, add the `PactKitCore` product to your target's dependencies:

```swift
.target(
  name: "YourAppTarget",
  dependencies: [
    .product(name: "PactKitCore", package: "PactKit")
  ]
)
```

-----

## Quick Start

Here's a brief example of how to establish a secure channel on the `Host` side (e.g., your iOS app).

```swift
import PactKitCore

// 1. Initialize the Host (do this once, preferably on a background thread)
let host = try Pact.Host()

// 2. Share the host's public identity key with your counterpart.
// (e.g., inject into a WebView, show as a QR code, etc.)
let identityKeyForCounterpart = host.identityPublicKey

// 3. When you receive a handshake request from the counterpart...
do {
  // The counterpart's ephemeral public key (e.g., received over a JS Bridge)
  let counterpartKeyData: Data = // ... get data from counterpart

  // 4. Establish the secure channel.
  // This performs the key exchange and signature verification.
  let (channel, response) = try host.establishChannel(with: counterpartKeyData)

  // 5. Send the `response` back to the counterpart to complete the handshake.
  // ... send response.ephemeralPublicKey and response.signature ...

  // 6. You can now use the channel for secure communication!
  let secretMessage = "Hello from the secure world!"
  let encrypted = try channel.encrypt(message: secretMessage)
} catch {
  print("An error occurred during handshake: \(error.localizedDescription)")
}
```

-----

## Documentation

For a detailed API reference, please visit our official documentation website, hosted on GitHub Pages. The site is automatically updated with the latest changes from the `main` branch.

**[Documentation](https://ryan-son.github.io/PactKit/main/documentation/pactkitcore/)**

-----

## Example Project

For a complete, runnable example of how to use PactKit with a SwiftUI and WKWebView, please see the `PactKit-iOS-Example` project in the `Examples/` directory.

-----

## License

PactKit is available under the MIT license. See the [LICENSE](https://www.google.com/search?q=LICENSE) file for more info.
