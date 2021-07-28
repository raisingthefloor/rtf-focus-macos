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

extension NSView {
    var bgColor: NSColor? {
        get {
            if let colorRef = layer?.backgroundColor {
                return NSColor(cgColor: colorRef)
            } else {
                return nil
            }
        }

        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.cgColor
        }
    }
}

extension String {
    static func randomString(length: Int = 5) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0 ..< length).map { _ in letters.randomElement()! })
    }
}

extension Bundle {
    static func bundleIDFor(appNamed appName: String) -> String? {
        if let appPath = NSWorkspace.shared.fullPath(forApplication: appName) {
            if let itsBundle = Bundle(path: appPath) {
                if let itsID = itsBundle.bundleIdentifier {
                    return itsID
                }
            } else {
                if let ownID = Bundle.main.bundleIdentifier {
                    return ownID
                }
            }
        }
        return nil
    }
}
