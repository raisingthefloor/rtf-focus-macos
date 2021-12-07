/*
 Copyright 2020 Raising the Floor - International

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

/*
 Abstract:
 This file contains the implementation of the app <-> provider IPC connection
 */

import Foundation
import Network
import os.log

/// App --> Provider IPC
@objc protocol ProviderCommunication {
    func register(_ completionHandler: @escaping (Bool) -> Void)
}

/// Provider --> App IPC
@objc protocol AppCommunication {
    func promptUser(aboutFlow flowInfo: [String: String], responseHandler: @escaping (Bool) -> Void)
    func getBlockURLs(responseHandler: @escaping ([String]) -> Void)
}

enum FlowInfoKey: String {
    case localPort
    case remoteAddress
}

/// The IPCConnection class is used by both the app and the system extension to communicate with each other
class IPCConnection: NSObject {
    // MARK: Properties

    var listener: NSXPCListener?
    var currentConnection: NSXPCConnection?
    weak var delegate: AppCommunication?
    static let shared = IPCConnection()
    static var groupName = "group.com.plenartech.Focus.url"

    // MARK: Methods

    /**
        The NetworkExtension framework registers a Mach service with the name in the system extension's NEMachServiceName Info.plist key.
        The Mach service name must be prefixed with one of the app groups in the system extension's com.apple.security.application-groups entitlement.
        Any process in the same app group can use the Mach service to communicate with the system extension.
     */
    private func extensionMachServiceName(from bundle: Bundle) -> String {
        guard let networkExtensionKeys = bundle.object(forInfoDictionaryKey: "NetworkExtension") as? [String: Any],
              let machServiceName = networkExtensionKeys["NEMachServiceName"] as? String else {
            fatalError("Mach service name is missing from the Info.plist")
        }

        return machServiceName
    }

    func startListener() {
        let machServiceName = extensionMachServiceName(from: Bundle.main)
        os_log("Starting XPC listener for mach service %@", machServiceName)

        let newListener = NSXPCListener(machServiceName: machServiceName)
        newListener.delegate = self
        newListener.resume()
        listener = newListener
    }

    /// This method is called by the app to register with the provider running in the system extension.
    func register(withExtension bundle: Bundle, delegate: AppCommunication, completionHandler: @escaping (Bool) -> Void) {
        self.delegate = delegate

        guard currentConnection == nil else {
            os_log("Already registered with the provider")
            completionHandler(true)
            return
        }

        let machServiceName = extensionMachServiceName(from: bundle)
        let newConnection = NSXPCConnection(machServiceName: machServiceName, options: [])

        // The exported object is the delegate.
        newConnection.exportedInterface = NSXPCInterface(with: AppCommunication.self)
        newConnection.exportedObject = delegate

        // The remote object is the provider's IPCConnection instance.
        newConnection.remoteObjectInterface = NSXPCInterface(with: ProviderCommunication.self)

        currentConnection = newConnection
        newConnection.resume()

        guard let providerProxy = newConnection.remoteObjectProxyWithErrorHandler({ registerError in
            os_log("Failed to register with the provider: %@", registerError.localizedDescription)
            self.currentConnection?.invalidate()
            self.currentConnection = nil
            completionHandler(false)
        }) as? ProviderCommunication else {
            fatalError("Failed to create a remote object proxy for the provider")
        }

        providerProxy.register(completionHandler)
    }

    /**
         This method is called by the provider to cause the app (if it is registered) to display a prompt to the user asking
         for a decision about a connection.
     */
    func promptUser(aboutFlow flowInfo: [String: String], responseHandler: @escaping (Bool) -> Void) -> Bool {
        guard let connection = currentConnection else {
            os_log("Cannot prompt user because the app isn't registered")
            return false
        }

        guard let appProxy = connection.remoteObjectProxyWithErrorHandler({ promptError in
            os_log("Failed to prompt the user: %@", promptError.localizedDescription)
            self.currentConnection = nil
            responseHandler(true)
        }) as? AppCommunication else {
            fatalError("Failed to create a remote object proxy for the app")
        }

        appProxy.promptUser(aboutFlow: flowInfo, responseHandler: responseHandler)

        return true
    }

//    public static func getBlockURLs() -> [String] {
//        os_log("BHAVI getBlockURLs  Method called")
//        let suiteName = IPCConnection.groupName
//        if let userDefaults = UserDefaults(suiteName: suiteName) {
//            let block_sites = userDefaults.array(forKey: "block_urls") as? [String] ?? []
//            os_log("BHAVI getBlockURLs  block_sites %{public}@", block_sites)
//            return block_sites
//        }
//        os_log("BHAVI getBlockURLs  Out SIDE IF")
//        return []
//    }

    func getBlockURLs(responseHandler: @escaping ([String]) -> Void) {
        guard let connection = currentConnection else {
            os_log("Cannot prompt user because the app isn't registered BHAVI")
            return
        }

        guard let appProxy = connection.remoteObjectProxyWithErrorHandler({ promptError in
            os_log("Failed to prompt the user BHAVI:  %{public}@", promptError.localizedDescription)
            self.currentConnection = nil
            responseHandler([])
        }) as? AppCommunication else {
            fatalError("Failed to create a remote object proxy for the app BHAVI")
        }
        appProxy.getBlockURLs(responseHandler: responseHandler)
    }
}

extension IPCConnection: NSXPCListenerDelegate {
    // MARK: NSXPCListenerDelegate

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        // The exported object is this IPCConnection instance.
        newConnection.exportedInterface = NSXPCInterface(with: ProviderCommunication.self)
        newConnection.exportedObject = self

        // The remote object is the delegate of the app's IPCConnection instance.
        newConnection.remoteObjectInterface = NSXPCInterface(with: AppCommunication.self)

        newConnection.invalidationHandler = {
            self.currentConnection = nil
        }

        newConnection.interruptionHandler = {
            self.currentConnection = nil
        }

        currentConnection = newConnection
        newConnection.resume()

        return true
    }
}

extension IPCConnection: ProviderCommunication {
    // MARK: ProviderCommunication

    func register(_ completionHandler: @escaping (Bool) -> Void) {
        os_log("App registered")
        completionHandler(true)
    }
}
