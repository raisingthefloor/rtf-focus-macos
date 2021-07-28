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

import Cocoa

let windowController: NSWindowController = NSWindowController(window: nil)
let appDelegate = NSApplication.shared.delegate as? AppDelegate

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var customSetting = NSStoryboard(name: "CustomSetting", bundle: nil).instantiateController(withIdentifier: "WindowController") as? WindowController

    var query: NSMetadataQuery? {
        willSet {
            if let query = self.query {
                query.stop()
            }
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        openFocus()
        setupStautsBarMenu()
//        addObserverToCheckAppLaunch()
        doSpotlightQuery()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func addObserverToCheckAppLaunch() {
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appDidLaunch(notification:)), name: NSWorkspace.willLaunchApplicationNotification, object: nil)
    }
}

// For Testing Methods
extension AppDelegate {
    public func doSpotlightQuery() {
        query = NSMetadataQuery()
        let predicate = NSPredicate(format: "kMDItemContentType == 'com.apple.application-bundle'")
        NotificationCenter.default.addObserver(self, selector: #selector(queryDidFinish(_:)), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: nil)
        query?.predicate = predicate
        query?.start()
    }

    @objc public func queryDidFinish(_ notification: NSNotification) {
        guard let query = notification.object as? NSMetadataQuery else {
            return
        }

        for result in query.results {
            guard let item = result as? NSMetadataItem else {
                print("Result was not an NSMetadataItem, \(result)")
                continue
            }
//            print("Spotlit Result: \(item.value(forAttribute: kMDItemIdentifier as String))")
//            print("item \(item.values(forAttributes: [kMDItemDisplayName as String, kMDItemPath as String]))")

            if let name = item.value(forAttribute: kMDItemDisplayName as String) as? String {
                if let bundleName = Bundle.bundleIDFor(appNamed: name) {
                    print("\n")
                    print("bundleName: \(bundleName)")
                }
            }
        }
    }
}

// MARK: Setup Status bar Menu

extension AppDelegate {
    @objc func appDidLaunch(notification: NSNotification) {
        if let app = notification.userInfo,
           let identifier = app["NSApplicationBundleIdentifier"] as? String {
            let runningApplications = NSWorkspace.shared.runningApplications
            // filter here to get only that application which are in block list and also check here if focus is running
            if let application = runningApplications.first(where: { application in
                application.bundleIdentifier == identifier
            }) {
                application.forceTerminate()
                kill(application.processIdentifier, SIGTERM)

                let controller = FocusDialogueViewC(nibName: "FocusDialogueViewC", bundle: nil)
                controller.dialogueType = .launch_app_alert
                windowController.contentViewController?.presentAsSheet(controller)
            }
        }
    }

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
        if let vc = WindowsManager.getVC(withIdentifier: "sidFloatingFocusViewC", ofType: FloatingFocusViewC.self) {
            vc.title = ""
            let window: NSWindow = {
                let w = NSWindow(contentViewController: vc)
                w.styleMask.remove(.fullScreen)
                w.styleMask.remove(.resizable)
                w.styleMask.remove(.miniaturizable)
                w.styleMask.remove(.closable)
                w.styleMask.remove(.miniaturizable)
                w.level = .floating
                return w
            }()

            if windowController.window == nil {
                windowController.window = window
            }
            windowController.showWindow(self)
        }
    }
}
