//
//  SessionInfoView.swift
//  Focus
//
//  Created by Bhavi on 25/08/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Cocoa

class SessionInfoView: NSView, NibView {
    @IBOutlet var mainView: NSView?

    @IBOutlet var lblTitle: NSTextField!

    @IBOutlet var lblHours: NSTextField!
    @IBOutlet var lblHoursV: NSTextField!
    @IBOutlet var lblBlock: NSTextField!
    @IBOutlet var lblBlockV: NSTextField!
    @IBOutlet var lblEnd: NSTextField!
    @IBOutlet var lblEndV: NSTextField!

    @IBOutlet var btnStop: CustomButton!

    init() {
        super.init(frame: NSRect.zero)
        _ = load(viaNib: "SessionInfoView")
        setUpText()
        setUpViews()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
}

extension SessionInfoView: BasicSetupType {
    func setUpText() {
        lblTitle.stringValue = NSLocalizedString("Session.focus_session", comment: "Focus Session") + "1"
        lblHours.stringValue = NSLocalizedString("Session.focus_session_has_run", comment: "Focus session has run for:")
        lblBlock.stringValue = NSLocalizedString("Session.using_block", comment: "Using blocklist:")
        lblEnd.stringValue = NSLocalizedString("Session.focus_session_end_at", comment: "Focus session ends at:")
        btnStop.title = NSLocalizedString("Session.stop_focus_session", comment: "Stop focus session")
    }

    func setUpViews() {
        btnStop.buttonColor = Color.very_light_grey
        btnStop.activeButtonColor = Color.very_light_grey
        btnStop.textColor = Color.black_color
        btnStop.borderColor = Color.dark_grey_border
        btnStop.borderWidth = 0.6
        btnStop.font = NSFont.systemFont(ofSize: 12, weight: .bold)
        lblHoursV.font = NSFont.systemFont(ofSize: 12, weight: .bold)
        lblBlockV.font = NSFont.systemFont(ofSize: 12, weight: .bold)
        lblEndV.font = NSFont.systemFont(ofSize: 12, weight: .bold)

        border_width = 0.6
        border_color = .black
    }
}
