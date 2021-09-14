//
//  WeekDaysCell.swift
//  Focus
//
//  Created by Bhavi on 13/09/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Cocoa

class WeekDaysCell: NSTableCellView {
    
    @IBOutlet var stackView: NSStackView!
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
    
    func configDays(){
        for day in WeekDays.days {
            let btn = NSButton(frame: NSRect(x: 0, y: 0, width: 25, height: 25))
            btn.tag = day.rawValue
            btn.font = NSFont.systemFont(ofSize: 10, weight: .regular)
            btn.title = day.short_name
            btn.corner_radius = btn.frame.height / 2
            btn.border_color = .black
            btn.border_width = 0.5
            stackView.addArrangedSubview(btn)
        }
    }

}


enum WeekDays: Int, CaseIterable {
    case mon = 0
    case tue
    case wed
    case thu
    case fri
    case sat
    case sun
    
    var short_name: String {
        switch self {
        case .mon:
            return "M"
        case .tue:
            return "T"
        case .wed:
            return "W"
        case .thu:
            return "T"
        case .fri:
            return "F"
        case .sat:
            return "S"
        case .sun:
            return "S"
        }
    }
    
    static var days: [WeekDays] = WeekDays.allCases
}
