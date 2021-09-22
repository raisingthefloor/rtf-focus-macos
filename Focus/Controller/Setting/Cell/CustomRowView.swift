//
//  CustomRowView.swift
//  Focus
//
//  Created by Bhavi on 22/09/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Cocoa
import Foundation

class RowView: NSTableRowView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        if isSelected == true {
            Color.selected_row_color.set()
            dirtyRect.fill()
        } else {
            Color.green_color.set()
            dirtyRect.fill()
        }
    }
}

class ClearRowView: NSTableRowView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.white.set()
        dirtyRect.fill()
    }
}
