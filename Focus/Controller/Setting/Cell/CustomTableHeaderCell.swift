/*
 Copyright 2020 Raising the Floor - International

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

class CustomTableHeaderCell: NSTableHeaderCell {
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        // skip super.drawWithFrame(), since that is what draws borders
        drawInterior(withFrame: cellFrame, in: controlView)
    }

    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        let titleRect = self.titleRect(forBounds: cellFrame)
        attributedStringValue.draw(in: titleRect)
    }
}

class TodayScheduleHeaderCell: NSTableHeaderCell {
    // Customize background tint for header cell
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        super.draw(withFrame: cellFrame, in: controlView)
        Color.tbl_header_color.set()
        cellFrame.fill()
    }

    // Customize text style/positioning for header cell
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        attributedStringValue = NSAttributedString(string: Date.getDayName().uppercased(), attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 10, weight: .semibold), NSAttributedString.Key.foregroundColor: Color.black_color, NSAttributedString.Key.paragraphStyle: paragraph])
        let offsetFrame = NSOffsetRect(drawingRect(forBounds: cellFrame), 4, 0)
        super.drawInterior(withFrame: offsetFrame, in: controlView)
    }
}
