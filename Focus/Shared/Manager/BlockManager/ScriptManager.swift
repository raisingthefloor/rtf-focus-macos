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

import AppleScriptObjC
import Carbon
import Foundation
import OSLog

class ScriptManager {
    static var shared = ScriptManager()

    var isFocus: Bool = false
    var i = 0

    func loadBrowserBlock(val: BrowserApp, isFocusing: Bool) {
        let blocklist = ["\"yahoo\"", "\"facebook\"", "\"instagram\""].joined(separator: ",")

        var error: NSDictionary?
//        for val in BrowserApp.allBrowsers {
        let sctriptVal = getActiveBrowserNBlock(blocklist: blocklist, isFocusing: isFocusing)

        updateFlag { val in
            print("val \(val)")
        }

        guard let script = NSAppleScript(source: sctriptVal) else { return }
        guard let outputString = script.executeAndReturnError(&error).stringValue else {
            if let error = error {
                print("Block Browser URL request failed with error: \(error.description)")
            }
            return
        }
        print(outputString)
//        }
    }

    func getActiveBrowserNBlock(blocklist: String, isFocusing: Bool) -> String {
        return
            "set urls to {\(blocklist)}" + "\n" +
            "set isFocus to false" + "\n" +

            "tell application \"System Events\" to set activeApp to get the name of every process whose background only is false" + "\n" +

            "repeat until isFocus" + "\n" +

            "if \"Safari\" is in activeApp then" + "\n" +
            "if application \"Safari\" is running then" + "\n" +
            "tell application \"Safari\"" + "\n" +
            "repeat with theURL in urls" + "\n" +
            "set (URL of every tab of every window where URL contains (contents of theURL)) to \"http://127.0.0.1\"" + "\n" +
            "end repeat" + "\n" +
            "delay 0.9" + "\n" +
            "end tell" + "\n" +
            "end if" + "\n" +
            "end if" + "\n" +

            "if \"Google Chrome\" is in activeApp then" + "\n" +
            "if application \"Google Chrome\" is running then" + "\n" +
            "tell application \"Google Chrome\"" + "\n" +
            "repeat with theURL in urls" + "\n" +
            "set (URL of every tab of every window where URL contains (contents of theURL)) to \"http://127.0.0.1\"" + "\n" +
            "end repeat" + "\n" +
            "delay 0.9" + "\n" +
            "end tell" + "\n" +
            "end if" + "\n" +
            "end if" + "\n" +
            "set isFocus to \(isFocus)" + "\n" +
            "end repeat"
    }

    func getSingleScriptVal(blocklist: String, name: String) -> String {
        return "set urls to {\(blocklist)}" + "\n" +
            "if application \"\(name)\" is running then" + "\n" +
            "repeat until application \"\(name)\" is not running" + "\n" +
            "repeat with theURL in urls" + "\n" +
            "tell application \"\(name)\"" + "\n" +
            "set (URL of every tab of every window where URL contains (contents of theURL)) to \"http://127.0.0.1\"" + "\n" +
            "end tell" + "\n" +
            "end repeat" + "\n" +
            "end repeat" + "\n" +
            "end if"
    }

    func stopBlockBrowser(browser: BrowserApp) {
        var error: NSDictionary?
        var backstr = "do JavaScript \"history.back()\" in every tab of every window"

        if browser == .chrome {
            backstr = "execute javascript \"history.go(-1)\" in every tab of every window"
        }

        let script_rule = "if application \"\(browser.name)\" is running then" + "\n" +
            "tell application \"\(browser.name)\"" + "\n" +
            "\(backstr)" + "\n" +
            "end tell" + "\n" +
            "end if"

        guard let script = NSAppleScript(source: script_rule) else { return }
        guard let outputString = script.executeAndReturnError(&error).stringValue else {
            if let error = error {
                print("App Stop request failed with error: \(error.description)")
            }
            return
        }
    }

    func callCustomScript(isFocus: Bool = true) {
        var error: NSDictionary?
        guard let path = Bundle.main.path(forResource: "BlockScript", ofType: "scpt") else { return }
        guard let script = NSAppleScript(contentsOf: URL(string: path)!, error: &error) else {
            if let error = error {
                print("App Stop request failed with error: \(error.description)")
            }
            return
        }
        guard let output = script.executeAndReturnError(&error).stringValue else {
            if let error = error {
                print("App Stop request failed with error: \(error.description)")
            }
            return
        }
        print("Output: \(output)")
    }

    func loadScriptBridge() {
        appDelegate?.browserBridge?.blockList = ["yahoo.com", "facebook.com", "instagram.com"]
        appDelegate?.browserBridge?.runBlockBrowser(isFocusRunning: true)
    }
}

extension ScriptManager {
    func stopApplicationToLaunch() {
        var error: NSDictionary?
        let script_rule = "tell application \"iTunes\" -- doesn't automatically launch app" + "\n" + "if it is running then" + "\n" + "pause"
            + "\n" + "end if" + "\n" + "end tell"

        guard let script = NSAppleScript(source: script_rule) else { return }
        guard let outputString = script.executeAndReturnError(&error).stringValue else {
            if let error = error {
                print("App Stop request failed with error: \(error.description)")

                if #available(macOS 11.0, *) {
                    os_log("App Stop request failed with error: \(error.description)")
                } else {
                    // Fallback on earlier versions
                }
            }
            return
        }
        print(outputString)
    }

    /* For Testing to Stop Script */
    func stopScript() -> Bool {
        return true
    }

    func updateFlag(callback: @escaping ((Bool) -> Void)) {
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            timer in
            print("iii: \(self.i)")
            if self.i == 20 {
                timer.invalidate()
                self.isFocus = true
                callback(true)
                return
            }
            self.i = self.i + 1
            callback(false)
        }
    }
}

enum BrowserApp {
    case chrome
    case safari
    case firefox
    case opera
    case other

    var name: String {
        switch self {
        case .chrome:
            return "Google Chrome"
        case .safari:
            return "Safari"
        case .firefox:
            return "Firefox"
        case .opera:
            return "Opera"
        case .other:
            return "Google Chrome"
        }
    }

    static var allBrowsers: [BrowserApp] {
        return [.safari, .chrome]
    }
}
