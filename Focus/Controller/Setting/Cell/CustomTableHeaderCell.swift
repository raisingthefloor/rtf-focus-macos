//
//  CustomTableHeaderCell.swift
//  Focus
//
//  Created by Bhavi on 22/09/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Cocoa

class CustomTableHeaderCell: NSTableHeaderCell {
    override init(textCell: String) {
        super.init(textCell: textCell)
        font = NSFont.systemFont(ofSize: 10, weight: .semibold)
        backgroundColor = Color.tbl_header_color
    }

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
