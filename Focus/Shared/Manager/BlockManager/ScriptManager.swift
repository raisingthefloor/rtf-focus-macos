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
import Foundation
import OSLog

class ScriptManager {
    static var shared = ScriptManager()

    func blockBrowserURLs() {
        var error: NSDictionary?
        for val in BrowserApp.allBrowsers {
            guard let script = NSAppleScript(source: val.script_rule) else { return }

            guard let outputString = script.executeAndReturnError(&error).stringValue else {
                if let error = error {
                    print("Get Browser URL request failed with error: \(error.description)")

                    if #available(macOS 11.0, *) {
                        os_log("Get Browser URL request failed with error: \(error.description)")
                    } else {
                        // Fallback on earlier versions
                    }
                }
                return
            }
            print(outputString)
        }
    }
}

enum BrowserApp {
    case chrome(String)
    case safari(String)
    case firefox(String)
    case opera(String)
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

    var script_rule: String {
        switch self {
        case let .chrome(host):
            return "repeat until application \"\(name)\" is not running" + "\n" +
                "if application \"\(name)\" is running then" + "\n" +
                "tell application \"\(name)\" " + "\n" +
                "set (URL of every tab of every window where URL contains \"\(host)\") to \"http://127.0.0.1\" " + "\n" +
                "end tell" + "\n" +
                "end if" + "\n" +
                "end repeat"
        case let .safari(host):
            return "repeat until application \"\(name)\" is not running" + "\n" +
                "if application \"\(name)\" is running then" + "\n" +
                "tell application \"\(name)\" " + "\n" +
                "set (URL of every tab of every window where URL contains \"\(host)\") to \"http://127.0.0.1\" " + "\n" +
                "end tell" + "\n" +
                "end if" + "\n" +
                "end repeat"

        case let .firefox(host):
            return "repeat until application \"\(name)\" is not running" + "\n" +
                "if application \"\(name)\" is running then" + "\n" +
                "tell application \"\(name)\" " + "\n" +
                "set (URL of every tab of every window where URL contains \"\(host)\") to \"http://127.0.0.1\" " + "\n" +
                "end tell" + "\n" +
                "end if" + "\n" +
                "end repeat"

        case let .opera(host):
            return "repeat until application \"\(name)\" is not running" + "\n" +
                "if application \"\(name)\" is running then" + "\n" +
                "tell application \"\(name)\" " + "\n" +
                "set (URL of every tab of every window where URL contains \"\(host)\") to \"http://127.0.0.1\" " + "\n" +
                "end tell" + "\n" +
                "end if" + "\n" +
                "end repeat"

        case .other:
            return "repeat until application \"\(name)\" is not running" + "\n" +
                "if application \"\(name)\" is running then" + "\n" +
                "tell application \"\(name)\" " + "\n" +
                "set (URL of every tab of every window where URL contains \"facebook.com\") to \"http://127.0.0.1\" " + "\n" +
                "end tell" + "\n" +
                "end if" + "\n" +
                "end repeat"
        }
    }

    static var allBrowsers: [BrowserApp] {
        return [.chrome("facebook.com")]
    }
}
