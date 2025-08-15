//
//  WebView.swift
//  PactKit-iOS-Example
//
//  Created by Geonhee on 8/13/25.
//

import Combine
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {

  let url: URL
  var model: HostModel

  func makeUIView(context: Context) -> WKWebView {
    let preferences = WKWebpagePreferences()
    preferences.allowsContentJavaScript = true

    let configuration = WKWebViewConfiguration()
    configuration.defaultWebpagePreferences = preferences
    configuration.userContentController.add(context.coordinator, name: "pactkit")

    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.navigationDelegate = context.coordinator

    webView.load(URLRequest(url: url))
    context.coordinator.subscribeToViewModelMessages(webView: webView)

    if #available(iOS 16.4, *) {
      webView.isInspectable = true
    }
    return webView
  }

  func updateUIView(_ uiView: WKWebView, context: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(model: model)
  }

  class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    @ObservedObject var model: HostModel
    private var cancellable: AnyCancellable?

    init(model: HostModel) {
      self.model = model
    }

    func subscribeToViewModelMessages(webView: WKWebView) {
      self.cancellable = model.messageToJS
        .sink { script in
          webView.evaluateJavaScript(script)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
      let key = model.getIdentityKeyForInjection()
      let script = "window.NATIVE_IDENTITY_PUBLIC_KEY = '\(key)';"
      webView.evaluateJavaScript(script) { _, error in
        if let error {
          print("Error injecting public key: \(error)")
        } else {
          print("✅ Successfully injected identity key into WebView.")
        }
      }
    }

    func userContentController(
      _ userContentController: WKUserContentController,
      didReceive message: WKScriptMessage
    ) {
      model.handleMessageFromJS(message.body)
    }
  }
}
