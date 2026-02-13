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
 * View Controller that hosts React Native content below a UINavigationBar.
 *
 * Features:
 * - Native UINavigationBar at the top
 * - React Native content fills remaining space
 * - Support for dynamic header updates via bridge
 * - PII-safe initialization with userId and authToken
 */
class RNHostViewController: UIViewController {

    private var reactRootView: RCTRootView?
    private var initialProps: [String: Any] = [:]
    private let bridgeDelegate = RNBridgeDelegate.shared

    // MARK: - Initialization

    init(userId: String, authToken: String, userName: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        // Store initial props (never log sensitive data)
        self.initialProps = [
            "userId": userId,
            "authToken": authToken
        ]
        if let userName = userName {
            self.initialProps["userName"] = userName
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        // Setup navigation bar
        setupNavigationBar()

        // Setup React Native container
        setupReactNativeContainer()

        // Setup bridge delegate
        bridgeDelegate.hostViewController = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Adjust React root view frame to account for navigation bar
        if let reactView = reactRootView {
            let navBarHeight = navigationController?.navigationBar.frame.height ?? 0
            reactView.frame = CGRect(
                x: 0,
                y: navBarHeight,
                width: view.bounds.width,
                height: view.bounds.height - navBarHeight
            )
        }
    }

    // MARK: - Setup Methods

    private func setupNavigationBar() {
        title = "FlyDubai"
        navigationItem.hidesBackButton = false

        // Add right button if needed
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Menu",
            style: .plain,
            target: self,
            action: #selector(handleRightButtonTap)
        )

        // Ensure navigation bar is visible
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    @objc private func handleRightButtonTap() {
        // This can be called from React Native via the bridge
    }

    private func setupReactNativeContainer() {
        do {
            guard let reactNativeHost = (UIApplication.shared.delegate as? RNAppDelegate)?.reactNativeHost else {
                throw NSError(domain: "RNSetup", code: 1, userInfo: [NSLocalizedDescriptionKey: "React Native host not available"])
            }

            let bridge = try reactNativeHost.get()
            let rootView = RCTRootView(
                bridge: bridge,
                moduleName: "FlyDubai",
                initialProperties: initialProps
            )

            rootView.backgroundColor = .white
            self.reactRootView = rootView

            view.addSubview(rootView)

            // Layout constraints
            rootView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                rootView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                rootView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                rootView.topAnchor.constraint(equalTo: view.topAnchor),
                rootView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

            print("React Native view loaded successfully")
        } catch {
            print("Failed to setup React Native: \(error.localizedDescription)")
            showError(error)
        }
    }

    // MARK: - Public Methods

    /**
     * Update the navigation bar title from React Native
     */
    func updateHeaderTitle(_ title: String) {
        DispatchQueue.main.async {
            self.title = title
        }
    }

    /**
     * Update the navigation bar right button from React Native
     */
    func setHeaderRightButton(_ label: String?, action: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            if let label = label {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                    title: label,
                    style: .plain,
                    target: self,
                    action: #selector(self.handleRightButtonTap)
                )
            } else {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }

    /**
     * Close React Native view and go back
     */
    func closeReactNativeView() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Private Methods

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
