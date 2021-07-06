//
//  AppDelegate.swift
//  Focus
//
//  Created by Bhavi on 16/06/21.
//

import Cocoa

let windowController: NSWindowController = NSWindowController(window: nil)
let appDelegate = NSApplication.shared.delegate as? AppDelegate

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var customSetting = NSStoryboard(name: "CustomSetting", bundle: nil).instantiateController(withIdentifier: "WindowController") as? WindowController

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        guard let statusButton = statusBarItem.button else { return }
        statusButton.title = "Focus".l10n()

        let statusMenu: NSMenu = {
            let menu = NSMenu()

            let openFocusItem: NSMenuItem = {
                let item = NSMenuItem(title: "Open Focus".l10n(), action: #selector(openFocus), keyEquivalent: "")
                item.tag = 1
                item.target = self
                return item
            }()

            let quitApplicationItem: NSMenuItem = {
                let item = NSMenuItem(title: "Quit".l10n(), action: #selector(terminate), keyEquivalent: "q")
                item.target = self
                item.tag = 2

                return item
            }()

            menu.addItem(openFocusItem)
            menu.addItem(.separator())
            menu.addItem(quitApplicationItem)
            return menu
        }()

        statusBarItem.menu = statusMenu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc
    func terminate(_ sender: NSMenuItem) {
        NSApp.terminate(sender)
    }

    @objc
    func openFocus(_ sender: NSMenuItem) {
        if let vc = WindowsManager.getVC(withIdentifier: "sidMenuController", ofType: MenuController.self) {
            let window: NSWindow = {
                let w = NSWindow(contentViewController: vc)
                w.styleMask.remove(.fullScreen)
                w.styleMask.remove(.resizable)
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
