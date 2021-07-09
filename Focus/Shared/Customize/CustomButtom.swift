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

@IBDesignable class CustomButtom: NSButton {
    @IBInspectable var cornerRadius: CGFloat = 5

    @IBInspectable var dxPadding: CGFloat = 10
    @IBInspectable var dyPadding: CGFloat = 10

    @IBInspectable var backgroundColor: NSColor = .blue

    @IBInspectable var imageName: String = "NSActionTemplate"

    override func draw(_ dirtyRect: NSRect) {
        // Set corner radius
        wantsLayer = true
        layer?.cornerRadius = cornerRadius

        // Darken background color when highlighted
        if isHighlighted {
            layer?.backgroundColor = backgroundColor.blended(
                withFraction: 0.2, of: .black
            )?.cgColor
        } else {
            layer?.backgroundColor = backgroundColor.cgColor
        }

        // Set Image
        imagePosition = .imageLeading
        image = NSImage(named: imageName)

        // Reset the bounds after drawing is complete
        let originalBounds = bounds
        defer { self.bounds = originalBounds }

        // Inset bounds by padding
        bounds = originalBounds.insetBy(
            dx: dxPadding, dy: dyPadding
        )

        // Super
        super.draw(dirtyRect)
    }
}
