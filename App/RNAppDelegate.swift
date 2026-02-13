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

import UIKit
import React

/**
 * Protocol for React Native app delegation
 * Implemented by AppDelegate to support React Native
 */
@objc protocol RNAppDelegate {
    var reactNativeHost: RCTReactNativeHost { get }
}

/**
 * AppDelegate extension for React Native support
 * Initializes React Native bridge and provides host for embeddings
 */
class RNAppDelegate: NSObject, UIApplicationDelegate, RNAppDelegate {

    var window: UIWindow?
    
    lazy var reactNativeHost: RCTReactNativeHost = {
        RCTReactNativeHost(
            bridge: nil,
            isNewArchitectureEnabled: false,
            turboModuleEnabled: false,
            jsEngineOverride: nil
        )
    }()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Initialize React Native
        _ = reactNativeHost.bridge

        return true
    }

    @objc
    class func sharedDelegate() -> RNAppDelegate? {
        return UIApplication.shared.delegate as? RNAppDelegate
    }
}
