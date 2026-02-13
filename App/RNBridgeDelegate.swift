/*
 * Copyright 2024 Sample Example
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import React

/**
 * Singleton delegate for managing React Native to native communication on iOS.
 *
 * Provides methods for:
 * - Opening native screens from React Native
 * - Updating native header from React Native
 * - Closing React Native view
 * - Emitting events between native and RN
 */
class RNBridgeDelegate: NSObject {
    static let shared = RNBridgeDelegate()

    weak var hostViewController: RNHostViewController?

    private override init() {
        super.init()
    }

    // MARK: - Navigation Bridge Methods

    /**
     * Open a native screen from React Native
     * Usage from RN: NativeModules.NavigationBridge.openNativeScreen("ProfileScreen", {userId: "123"})
     */
    func openNativeScreen(screenName: String, params: [String: Any]?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let hostVC = self.hostViewController else {
                print("No host view controller available")
                return
            }

            print("Opening native screen: \(screenName)")

            switch screenName {
            case "ProfileScreen":
                self.openProfileScreen(with: params)
            default:
                print("Unknown screen: \(screenName)")
            }
        }
    }

    /**
     * Update the native header
     * Usage from RN: NativeModules.NavigationBridge.updateHeader("New Title", "Button Label")
     */
    func updateHeader(title: String, rightButtonLabel: String?) {
        hostViewController?.updateHeaderTitle(title)
        if let label = rightButtonLabel {
            hostViewController?.setHeaderRightButton(label)
        }
    }

    /**
     * Close React Native view
     * Usage from RN: NativeModules.NavigationBridge.closeRNView()
     */
    func closeRNView() {
        hostViewController?.closeReactNativeView()
    }

    /**
     * Emit event to React Native
     * Usage from native: RNBridgeDelegate.shared.emitToReactNative("eventName", ["data": "value"])
     */
    func emitToReactNative(eventName: String, data: [String: Any]?) {
        // This would be implemented with RCTDeviceEventEmitter
        print("Emitting to React Native: \(eventName)")
    }

    // MARK: - Native Screen Navigation

    private func openProfileScreen(with params: [String: Any]?) {
        guard let hostVC = hostViewController,
              let navController = hostVC.navigationController else {
            return
        }

        // Create a simple profile screen
        let profileVC = UIViewController()
        profileVC.title = "Native Profile"
        profileVC.view.backgroundColor = .white

        // Add some content
        let label = UILabel()
        label.text = "This is a native iOS screen opened from React Native.\n\nUserId: \(params?["userId"] as? String ?? "N/A")"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        profileVC.view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: profileVC.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: profileVC.view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: profileVC.view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: profileVC.view.trailingAnchor, constant: -16)
        ])

        navController.pushViewController(profileVC, animated: true)
    }
}

/**
 * Native module for React Native bridge communication
 * Exposes NavigationBridge methods to JavaScript
 */
@objc(RNNavigationBridge)
class RNNavigationBridge: NSObject, RCTBridgeModule {

    static func moduleName() -> String {
        return "NavigationBridge"
    }

    static func requiresMainQueueSetup() -> Bool {
        return true
    }

    @objc(openNativeScreen:params:resolver:rejecter:)
    func openNativeScreen(
        screenName: String,
        params: [String: Any]?,
        resolver: @escaping RCTPromiseResolveBlock,
        rejecter: @escaping RCTPromiseRejectBlock
    ) {
        RNBridgeDelegate.shared.openNativeScreen(screenName: screenName, params: params)
        resolver(true)
    }

    @objc(updateHeader:rightButtonLabel:resolver:rejecter:)
    func updateHeader(
        title: String,
        rightButtonLabel: String?,
        resolver: @escaping RCTPromiseResolveBlock,
        rejecter: @escaping RCTPromiseRejectBlock
    ) {
        RNBridgeDelegate.shared.updateHeader(title: title, rightButtonLabel: rightButtonLabel)
        resolver(true)
    }

    @objc(closeRNView:rejecter:)
    func closeRNView(
        resolver: @escaping RCTPromiseResolveBlock,
        rejecter: @escaping RCTPromiseRejectBlock
    ) {
        RNBridgeDelegate.shared.closeRNView()
        resolver(true)
    }

    @objc(emitToNative:data:resolver:rejecter:)
    func emitToNative(
        eventName: String,
        data: [String: Any]?,
        resolver: @escaping RCTPromiseResolveBlock,
        rejecter: @escaping RCTPromiseRejectBlock
    ) {
        print("Native event emitted: \(eventName)")
        resolver(true)
    }
}
