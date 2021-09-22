//
//  TableHeaderView.swift
//  Focus
//
//  Created by Bhavi on 22/09/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Cocoa

class TableHeaderView: NSTableHeaderView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        Color.tbl_header_color.set()
        dirtyRect.fill()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
    }
}
