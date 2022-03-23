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

@objc(NSObject) protocol AppleScriptProtocol {
    var b_list: [String] { get set }
    var app_list: [String] { get set }
    var isFocusing: Bool { get set }
    var app_names: [String] { get set }
    var isCB: Bool { get set }
    var isOpera: Bool { get set }
    var isBB: Bool { get set }
    var isViv: Bool { get set }

    func runBlockBrowser()
    func stopScript()
    func runUnblockBrowser()
    func blockApplication() -> Bool
    func logoutAlert()
    func launchMyApp()
    func quiteApp()
    func setDoNoDisturbTo(_: String)
    func quitActivityMonitor()
//    func doesBrowserExist(appName: String) -> Bool
}

class BrowserScript {
    static func load() {
        Bundle.main.loadAppleScriptObjectiveCScripts()
    }

    static func loadScript() -> AnyObject {
        let scriptObj: AnyClass? = NSClassFromString("BrowserBridge")
        let obj = scriptObj!.alloc()
        return obj as AnyObject
    }
}

enum BrowserApp: String {
    case chrome
    case safari
    case firefox
    case opera
    case other
    case vivaldi

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
        case .vivaldi:
            return "Vivaldi"
        case .other:
            return "Google Chrome"
        }
    }

    static var browserName: [String] {
        return [BrowserApp.safari.name, BrowserApp.chrome.name, BrowserApp.firefox.name, BrowserApp.opera.name]
    }

    static var allBrowsers: [BrowserApp] {
        return [.safari, .chrome, .firefox, .opera]
    }
}
