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

let windowController: NSWindowController = NSWindowController(window: nil)
let appDelegate = NSApplication.shared.delegate as? AppDelegate

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var customSetting = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "WindowController") as? WindowController
    var browserBridge: AppleScriptProtocol?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        openFocus()
        setupStautsBarMenu()

        //  Application Block Functionality
//        AppManager.shared.addObserverToCheckAppLaunch()
//        AppManager.shared.doSpotlightQuery()
        
        //  Browser URL Block Functionality
//        DispatchQueue.global(qos: .userInteractive).async {
//            self.loadScript()
//        }
    }

    func loadScript() {
        BrowserScript.load()
        guard let bridgeScript = BrowserScript.loadScript() as? AppleScriptProtocol else { return }
        browserBridge = bridgeScript
        browserBridge?.b_list = ["in.yahoo.com", "www.instagram.com", "www.facebook.com"]
        browserBridge?.app_list = ["Safari", "TV"]
        browserBridge?.runBlockBrowser()
        let value = browserBridge?.blockApplication()
        if value == true {
            let controller = FocusDialogueViewC(nibName: "FocusDialogueViewC", bundle: nil)
            controller.dialogueType = .launch_block_app_alert
            windowController.contentViewController?.presentAsSheet(controller)
        }
        //    browserBridge?.runPermission()

        print(AppleScriptProtocol.self)
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
