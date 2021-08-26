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
import Foundation

extension NSMutableAttributedString {
    class func getAttributedString(fromString string: String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: string)
    }

    func apply(attribute: [NSAttributedString.Key: Any], subString: String) {
        if let range = string.range(of: subString) {
            apply(attribute: attribute, onRange: NSRange(range, in: string))
        }
    }

    func apply(attribute: [NSAttributedString.Key: Any], onRange range: NSRange) {
        if range.location != NSNotFound {
            setAttributes(attribute, range: range)
        }
    }

    /*Color Attribute*/
    func apply(color: NSColor, subString: String) {
        if let range = string.range(of: subString) {
            apply(color: color, onRange: NSRange(range, in: string))
        }
    }

    // Apply color on given range
    func apply(color: NSColor, onRange: NSRange) {
        addAttributes([NSAttributedString.Key.foregroundColor: color],
                      range: onRange)
    }

    /* Font Attribute*/
    // Apply font on substring
    func apply(font: NSFont, subString: String) {
        if let range = string.range(of: subString) {
            apply(font: font, onRange: NSRange(range, in: string))
        }
    }

    // Apply font on given range
    func apply(font: NSFont, onRange: NSRange) {
        addAttributes([NSAttributedString.Key.font: font], range: onRange)
    }

    /* Background Color Attribute */
    // Apply background color on substring
    func apply(backgroundColor: NSColor, subString: String) {
        if let range = string.range(of: subString) {
            apply(backgroundColor: backgroundColor, onRange: NSRange(range, in: string))
        }
    }

    // Apply background color on given range
    func apply(backgroundColor: NSColor, onRange: NSRange) {
        addAttributes([NSAttributedString.Key.backgroundColor: backgroundColor],
                      range: onRange)
    }

    /* Underline Attribute */
    // Underline string
    func underLine(subString: String) {
        if let range = string.range(of: subString) {
            underLine(onRange: NSRange(range, in: string))
        }
    }

    // Underline string on given range
    func underLine(onRange: NSRange) {
        addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue],
                      range: onRange)
    }

    /* Strikethrough Attribute */
    // Apply Strikethrough on substring
    func strikeThrough(thickness: Int, subString: String) {
        if let range = string.range(of: subString) {
            strikeThrough(thickness: thickness, onRange: NSRange(range, in: string))
        }
    }

    // Apply Strikethrough on given range
    func strikeThrough(thickness: Int, onRange: NSRange) {
        addAttributes([NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.thick.rawValue],
                      range: onRange)
    }

    /* Stroke Attribute */
    // Apply stroke on substring
    func applyStroke(color: NSColor, thickness: Int, subString: String) {
        if let range = string.range(of: subString) {
            applyStroke(color: color, thickness: thickness, onRange: NSRange(range, in: string))
        }
    }

    // Apply stroke on give range
    func applyStroke(color: NSColor, thickness: Int, onRange: NSRange) {
        addAttributes([NSAttributedString.Key.strokeColor: color],
                      range: onRange)
        addAttributes([NSAttributedString.Key.strokeWidth: thickness],
                      range: onRange)
    }

    /* Shadow Color Attribute */
    // Apply shadow color on substring
    func applyShadow(shadowColor: NSColor, shadowWidth: CGFloat,
                     shadowHeigt: CGFloat, shadowRadius: CGFloat,
                     subString: String) {
        if let range = string.range(of: subString) {
            applyShadow(shadowColor: shadowColor, shadowWidth: shadowWidth,
                        shadowHeigt: shadowHeigt, shadowRadius: shadowRadius,
                        onRange: NSRange(range, in: string))
        }
    }

    // Apply shadow color on given range
    func applyShadow(shadowColor: NSColor, shadowWidth: CGFloat,
                     shadowHeigt: CGFloat, shadowRadius: CGFloat,
                     onRange: NSRange) {
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: shadowWidth, height: shadowHeigt)
        shadow.shadowColor = shadowColor
        shadow.shadowBlurRadius = shadowRadius
        addAttributes([NSAttributedString.Key.shadow: shadow], range: onRange)
    }

    /* Paragraph Style  Attribute */
    // Apply paragraph style on substring
    func alignment(alignment: NSTextAlignment, subString: String) {
        if let range = string.range(of: subString) {
            self.alignment(alignment: alignment, onRange: NSRange(range, in: string))
        }
    }

    // Apply paragraph style on give range
    func alignment(alignment: NSTextAlignment, onRange: NSRange) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: onRange)
    }
}
