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

struct Color {
    static let light_blue_color = NSColor(hex: "#D8E2F3", alpha: 1)
    static let green_color = NSColor(hex: "#009F01", alpha: 1)
    static let red_color = NSColor(hex: "#C00500", alpha: 1)
    static let navy_blue_color = NSColor(hex: "#011F60", alpha: 1)
}

extension String {
    func conformsTo(_ pattern: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: self)
    }
}

extension NSColor {
    convenience init(hex: Int, alpha: Float) {
        self.init(
            calibratedRed: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0xFF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: 1.0
        )
    }

    convenience init(hex: String, alpha: Float) {
        // Handle two types of literals: 0x and # prefixed
        var cleanedString = ""
        if hex.hasPrefix("0x") {
            cleanedString = String(hex[hex.index(cleanedString.startIndex, offsetBy: 2) ... hex.endIndex])
        } else if hex.hasPrefix("#") {
            cleanedString = String(hex[hex.index(cleanedString.startIndex, offsetBy: 1) ... hex.endIndex])
        }

        // Ensure it only contains valid hex characters 0
        let validHexPattern = "[a-fA-F0-9]+"
        if cleanedString.conformsTo(validHexPattern) {
            var value: UInt32 = 0
            Scanner(string: cleanedString).scanHexInt32(&value)
            self.init(hex: Int(value), alpha: 1)
        } else {
            fatalError("Unable to parse color?")
        }
    }
}
