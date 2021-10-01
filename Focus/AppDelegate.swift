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

import AppleScriptObjC
import Cocoa

let appDelegate = NSApplication.shared.delegate as? AppDelegate

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var browserBridge: AppleScriptProtocol?
    var windowController: NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Setup the Focus button
        loadScript()

        openFocus()

        setupStautsBarMenu()
        // Get All application from the system and store in DB
        AppManager.shared.doSpotlightQuery()
    }

    func loadScript() {
        BrowserScript.load()
        guard let bridgeScript = BrowserScript.loadScript() as? AppleScriptProtocol else { return }
        browserBridge = bridgeScript
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

// MARK: Setup Status bar Menu

extension AppDelegate {
    func setupStautsBarMenu() {
        guard let statusButton = statusBarItem.button else { return }
        statusButton.title = "Focus"

        let statusMenu: NSMenu = {
            let menu = NSMenu()
            let quitApplicationItem: NSMenuItem = {
                let item = NSMenuItem(title: "Quit", action: #selector(terminate), keyEquivalent: "q")
                item.target = self
                item.tag = 2

                return item
            }()
            menu.addItem(quitApplicationItem)
            return menu
        }()

        statusBarItem.menu = statusMenu
    }

    @objc
    func terminate(_ sender: NSMenuItem) {
        NSApp.terminate(sender)
    }

    func openFocus() {
        windowController = WindowsManager.getWindowC(withIdentifier: "sidWindowController", ofType: NSWindowController.self)
        windowController?.showWindow(self)
    }
}
