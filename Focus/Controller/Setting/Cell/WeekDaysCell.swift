//
//  WeekDaysCell.swift
//  Focus
//
//  Created by Bhavi on 13/09/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Cocoa

class WeekDaysCell: NSTableCellView {
    @IBOutlet var btnDay: NSButton!
    @IBOutlet var btnM: NSButton!
    @IBOutlet var btnT: NSButton!
    @IBOutlet var btnW: NSButton!
    @IBOutlet var btnTh: NSButton!
    @IBOutlet var btnF: NSButton!
    @IBOutlet var btnS: NSButton!

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        setUpText()
        setUpViews()
    }
}

extension WeekDaysCell: BasicSetupType {
    func setUpText() {
    }

    func setUpViews() {
    }

    func configBlockCell() {
        btnDay.title = BlockType.application.title
        btnDay.title = BlockType.web.title
    }

    func bindTarget(target: AnyObject?) {
        btnDay.target = target
        btnDay.tag = BlockType.application.rawValue
    }

    func configScheduleActionCell(isPause: Bool) {
        btnDay.title = isPause ? "🚫" : "⏸"
    }
}
