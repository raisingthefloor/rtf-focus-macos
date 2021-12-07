/* Copyright 2020 Raising the Floor - International

 Licensed under the New BSD license. You may not use this file except in
 compliance with this License.

 You may obtain a copy of the License at
 https://github.com/GPII/universal/blob/master/LICENSE.txt

 The R&D leading to these results received funding from the:
 * Rehabilitation Services Administration, US Dept. of Education under
   grant H421A150006 (APCP)
 * National Institute on Disability, Independent Living, and
   Rehabilitation Research (NIDILRR)
 * Administration for Independent Living & Dept. of Education under grants
   H133E080022 (RERC-IT) and H133E130028/90RE5003-01-00 (UIITA-RERC)
 * European Union's Seventh Framework Programme (FP7/2007-2013) grant
   agreement nos. 289016 (Cloud4all) and 610510 (Prosperity4All)
 * William and Flora Hewlett Foundation
 * Ontario Ministry of Research and Innovation
 * Canadian Foundation for Innovation
 * Adobe Foundation
 * Consumer Electronics Association Foundation
 */

import Cocoa
import Foundation
import NetworkExtension
import os.log
import SystemExtensions

enum NetworkStatus {
    case stopped
    case indeterminate
    case running
}

class FocusFirewall: NSObject {
    static var shared = FocusFirewall()

    // Get the Bundle of the system extension.
    lazy var extensionBundle: Bundle = {
        let extensionsDirectoryURL = URL(fileURLWithPath: "Contents/Library/SystemExtensions", relativeTo: Bundle.main.bundleURL)
        let extensionURLs: [URL]
        do {
            extensionURLs = try FileManager.default.contentsOfDirectory(at: extensionsDirectoryURL,
                                                                        includingPropertiesForKeys: nil,
                                                                        options: .skipsHiddenFiles)
        } catch let error {
            fatalError("Failed to get the contents of \(extensionsDirectoryURL.absoluteString): \(error.localizedDescription)")
        }

        guard let extensionURL = extensionURLs.first else {
            fatalError("Failed to find any system extensions")
        }

        guard let extensionBundle = Bundle(url: extensionURL) else {
            fatalError("Failed to create a bundle with URL \(extensionURL.absoluteString)")
        }

        return extensionBundle
    }()

    var observer: Any?
    var status: NetworkStatus = .stopped
    var block_sites: [String] = []

    func initialConfiguration() {
        loadFilterConfiguration { success in
            guard success else {
                self.status = .stopped
                return
            }

            self.observer = NotificationCenter.default.addObserver(forName: .NEFilterConfigurationDidChange,
                                                                   object: NEFilterManager.shared(),
                                                                   queue: .main) { [weak self] _ in
                self?.updateStatus()
            }
        }
    }

    func removeObserver() {
        guard let changeObserver = observer else {
            return
        }
        NotificationCenter.default.removeObserver(changeObserver, name: .NEFilterConfigurationDidChange, object: NEFilterManager.shared())
    }

    func updateStatus() {
        if NEFilterManager.shared().isEnabled {
            registerWithProvider()
        } else {
            status = .stopped
        }
    }
}

extension FocusFirewall {
    func saveBlockUrls() {
        let suiteName = IPCConnection.groupName
        if let userDefaults = UserDefaults(suiteName: suiteName) {
            userDefaults.set(block_sites, forKey: "block_urls")
            userDefaults.synchronize()
        }
    }

    func getSaveUrls() -> [String] {
        let suiteName = IPCConnection.groupName
        print("suiteName :::: \(suiteName)")
        if let userDefaults = UserDefaults(suiteName: suiteName) {
            let block_sites = userDefaults.array(forKey: "block_urls") as? [String] ?? []
            print("block_sites In  Controller :::: \(block_sites)")
            return block_sites
        }
        return []
    }

    func startFilter() {
        guard !NEFilterManager.shared().isEnabled else {
            registerWithProvider()
            return
        }

        guard let extensionIdentifier = extensionBundle.bundleIdentifier else {
            return
        }

        // Start by activating the system extension
        let activationRequest = OSSystemExtensionRequest.activationRequest(forExtensionWithIdentifier: extensionIdentifier, queue: .main)
        activationRequest.delegate = self
        OSSystemExtensionManager.shared.submitRequest(activationRequest)
    }

    func disableFilterManager() {
        let filterManager = NEFilterManager.shared()
        guard filterManager.isEnabled else {
            return
        }

        filterManager.isEnabled = false
        filterManager.saveToPreferences { saveError in
            DispatchQueue.main.async {
                if let error = saveError {
                    os_log("Failed to disable the filter configuration: %@", error.localizedDescription)
                    return
                }
            }
        }
    }

    func enableFilterManager() {
        let filterManager = NEFilterManager.shared()
        guard !filterManager.isEnabled else {
            return
        }

        filterManager.isEnabled = true
        filterManager.saveToPreferences { saveError in
            DispatchQueue.main.async {
                if let error = saveError {
                    os_log("Failed to disable the filter configuration: %@", error.localizedDescription)
                    return
                }
            }
        }
    }

    func stopFilter() {
        let filterManager = NEFilterManager.shared()
        status = .indeterminate
        guard filterManager.isEnabled else {
            status = .stopped
            return
        }

        loadFilterConfiguration { success in
            guard success else {
                self.status = .running
                return
            }

            // Disable the content filter configuration
            filterManager.isEnabled = false
            filterManager.saveToPreferences { saveError in
                DispatchQueue.main.async {
                    if let error = saveError {
                        os_log("Failed to disable the filter configuration: %@", error.localizedDescription)
                        self.status = .running
                        return
                    }

                    self.status = .stopped
                }
            }
        }
    }
}

extension FocusFirewall: OSSystemExtensionRequestDelegate {
    // MARK: OSSystemExtensionActivationRequestDelegate

    func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
        guard result == .completed else {
            os_log("Unexpected result %d for system extension request", result.rawValue)
            status = .stopped
            return
        }

        enableFilterConfiguration()
    }

    func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {
        print("System extension request failed: %@", error.localizedDescription)
        status = .stopped
    }

    func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
        print("Extension %@ requires user approval", request.identifier)
    }

    func request(_ request: OSSystemExtensionRequest,
                 actionForReplacingExtension existing: OSSystemExtensionProperties,
                 withExtension extension: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction {
        print("Replacing extension %@ version %@ with version %@", request.identifier, existing.bundleShortVersion, `extension`.bundleShortVersion)
        return .replace
    }
}

extension FocusFirewall {
    // MARK: Content Filter Configuration Management

    func loadFilterConfiguration(completionHandler: @escaping (Bool) -> Void) {
        NEFilterManager.shared().loadFromPreferences { loadError in
            DispatchQueue.main.async {
                var success = true
                if let error = loadError {
                    print("Failed to load the filter configuration: %@", error.localizedDescription)
                    os_log("Failed to load the filter configuration: %@", error.localizedDescription)
                    success = false
                }
                completionHandler(success)
            }
        }
    }

    func enableFilterConfiguration() {
        let filterManager = NEFilterManager.shared()
        guard !filterManager.isEnabled else {
            registerWithProvider()
            return
        }

        loadFilterConfiguration { success in
            guard success else {
                self.status = .stopped
                return
            }

            if filterManager.providerConfiguration == nil {
                let providerConfiguration = NEFilterProviderConfiguration()
                providerConfiguration.filterSockets = true
                providerConfiguration.filterPackets = false
                filterManager.providerConfiguration = providerConfiguration
                if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
                    filterManager.localizedDescription = appName
                }
            }

            filterManager.isEnabled = true

            filterManager.saveToPreferences { saveError in
                DispatchQueue.main.async {
                    if let error = saveError {
                        os_log("Failed to save the filter configuration: %@", error.localizedDescription)
                        self.status = .stopped
                        return
                    }

                    self.registerWithProvider()
                }
            }
        }
    }

    // MARK: ProviderCommunication

    func registerWithProvider() {
        IPCConnection.shared.register(withExtension: extensionBundle, delegate: self) { success in
            DispatchQueue.main.async {
                self.status = (success ? .running : .stopped)
            }
        }
    }
}

extension FocusFirewall: AppCommunication {
    func promptUser(aboutFlow flowInfo: [String: String], responseHandler: @escaping (Bool) -> Void) {
    }

    func getBlockURLs(responseHandler: @escaping ([String]) -> Void) {
        print("block_sites :::  \(FocusFirewall.shared.block_sites)")
        let urls = FocusFirewall.shared.block_sites
        responseHandler(urls)
    }
}
