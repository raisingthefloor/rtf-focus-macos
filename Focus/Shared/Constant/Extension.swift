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

extension NSTextField {
    func addUnderline() {
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: Color.blue_color, .underlineStyle: NSUnderlineStyle.single.rawValue]
        attributedStringValue = NSAttributedString(string: stringValue, attributes: attributes)
    }
}

extension String {
    static func randomString(length: Int = 5) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0 ..< length).map { _ in letters.randomElement()! })
    }

    var isValidUrl: Bool {
        let urlRegEx = "((?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: self)
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

public extension NSView {
    var border_color: NSColor? {
        get {
            guard let color = layer?.borderColor else { return nil }
            return NSColor(cgColor: color)
        }
        set {
            wantsLayer = true
            layer?.borderColor = newValue?.cgColor
        }
    }

    var border_width: CGFloat {
        get {
            return layer?.borderWidth ?? 0
        }
        set {
            wantsLayer = true
            layer?.borderWidth = newValue
        }
    }

    var corner_radius: CGFloat {
        get {
            return layer?.cornerRadius ?? 0
        }
        set {
            wantsLayer = true
            layer?.masksToBounds = true
            layer?.cornerRadius = newValue.magnitude
        }
    }

    var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }

    var shadowColor: NSColor? {
        get {
            guard let color = layer?.shadowColor else { return nil }
            return NSColor(cgColor: color)
        }
        set {
            wantsLayer = true
            layer?.shadowColor = newValue?.cgColor
        }
    }

    var shadowOffset: CGSize {
        get {
            return layer?.shadowOffset ?? CGSize.zero
        }
        set {
            wantsLayer = true
            layer?.shadowOffset = newValue
        }
    }

    var shadowOpacity: Float {
        get {
            return layer?.shadowOpacity ?? 0
        }
        set {
            wantsLayer = true
            layer?.shadowOpacity = newValue
        }
    }

    var shadowRadius: CGFloat {
        get {
            return layer?.shadowRadius ?? 0
        }
        set {
            wantsLayer = true
            layer?.shadowRadius = newValue
        }
    }

    var background_color: NSColor? {
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

    var size: CGSize {
        get {
            return frame.size
        }
        set {
            width = newValue.width
            height = newValue.height
        }
    }

    var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
}

// MARK: - Methods

public extension NSView {
    func addSubviews(_ subviews: [NSView]) {
        subviews.forEach { addSubview($0) }
    }

    func removeSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
}
