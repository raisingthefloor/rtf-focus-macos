//
//  LabelCell.swift
//  Focus
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

import Cocoa

class LabelCell: NSTableCellView {
    @IBOutlet var view: NSView!
    @IBOutlet var lblTitle: NSTextField!

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        setUpText()
        setUpViews()
    }
}

extension LabelCell: BasicSetupType {
    func setUpText() {
    }

    func setUpViews() {
        if lblTitle != nil {
        }
    }
}

extension LabelCell {
    func configSettingMenu(value: String) {
        lblTitle.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        lblTitle.stringValue = value
        lblTitle.textColor = .white
    }

    func setupTime(value: String) {
        lblTitle.stringValue = value
        lblTitle.font = NSFont.systemFont(ofSize: 10, weight: .regular)
    }

    func setupSart(value: String) {
        lblTitle.stringValue = value
        lblTitle.font = NSFont.systemFont(ofSize: 12, weight: .regular)
    }

    func setupColor(objFS: Focus_Schedule) {
        let color_type = ColorType(rawValue: Int(objFS.color_type))
        let color = NSColor(objFS.session_color ?? "#DCEFE6")

        lblTitle.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        lblTitle.textColor = .black
        lblTitle.stringValue = objFS.block_list_name ?? "-"

        view.background_color = ((color_type == .hollow) ? Color.list_bg_color : color)
        view.border_color = ((color_type == .hollow) ? color : .clear)
        view.border_width = 2.5
    }
}
