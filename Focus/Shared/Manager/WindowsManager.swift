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

import AppKit
import Cocoa
import Foundation

struct WindowsManager {
    static func getVC<T: NSViewController>(withIdentifier identifier: String, ofType: T.Type?, storyboard: String = "Main", bundle: Bundle? = nil) -> T? {
        let storyboard = NSStoryboard(name: storyboard, bundle: bundle)

        guard let vc: T = storyboard.instantiateController(withIdentifier: identifier) as? T else {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = "Error initiating the viewcontroller"
            alert.runModal()
            return nil
        }
        return vc
    }

    static func getWindowC<T: NSWindowController>(withIdentifier identifier: String, ofType: T.Type?, storyboard: String = "Main", bundle: Bundle? = nil) -> T? {
        let storyboard = NSStoryboard(name: storyboard, bundle: bundle)

        guard let vc: T = storyboard.instantiateController(withIdentifier: identifier) as? T else {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = "Error initiating the windowcontroller"
            alert.runModal()
            return nil
        }
        return vc
    }
}

// MARK: Block Web and Display Restart window Script Methods

extension WindowsManager {
    static func openSystemLogoutDialog() {
        DispatchQueue.global(qos: .userInteractive).async {
            appDelegate?.browserBridge?.logoutAlert()
        }
    }

    static func blockWebSite() {
        let arrWeb = DBManager.shared.getCurrentBlockList().webs
        if !arrWeb.isEmpty {
            DispatchQueue.global(qos: .userInteractive).async {
                appDelegate?.browserBridge?.b_list = arrWeb.compactMap({ $0.url })
                appDelegate?.browserBridge?.runBlockBrowser()
            }
        }
    }

    static func stopBlockWebSite() {
        appDelegate?.browserBridge?.stopScript()
    }

    static func launchMyapp() {
        DispatchQueue.global(qos: .userInteractive).async {
            appDelegate?.browserBridge?.launchMyApp()
        }
    }
}

// MARK: DND Functionality

extension WindowsManager {
    static func runDndCommand(cmd: String) {
        let pipe = Pipe()
        let process = Process()
        let scriptPath = Bundle.main.path(forResource: "dnd", ofType: ".sh") ?? ""
        process.launchPath = "/bin/sh"
        process.arguments = [scriptPath, String(format: "%@", cmd)]
        process.standardOutput = pipe
        process.launch()
    }
}
