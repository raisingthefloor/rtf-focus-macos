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

class SessionInfoView: NSView, NibView {
    @IBOutlet var mainView: NSView?

    @IBOutlet var titleV: NSView?
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
        lblHoursV.font = NSFont.systemFont(ofSize: 11, weight: .bold)
        lblBlockV.font = NSFont.systemFont(ofSize: 11, weight: .bold)
        lblEndV.font = NSFont.systemFont(ofSize: 11, weight: .bold)

        border_width = 0.6
        border_color = .black
    }

    func setupSingleData() {
        titleV?.isHidden = true
        lblHours.alignment = .right
        lblBlock.alignment = .right
        lblEnd.alignment = .right

        let objFocus = DBManager.shared.getCurrentBlockList().objFocus
        let objB = DBManager.shared.getCurrentBlockList().objBl
        let focus_length = Int(objFocus?.used_focus_time ?? 100).secondsToTime()

        var time = ""
        if focus_length.timeInHours != 0 {
            time = "\(focus_length.timeInHours) hrs \(focus_length.timeInMinutes) minutes"
        } else {
            time = "\(focus_length.timeInMinutes) minutes \(focus_length.timeInSeconds) sec"
        }

        lblHoursV.stringValue = time

        var list_name = objB?.name ?? "-"
        if objB?.restart_computer ?? false || objB?.random_character ?? false {
            list_name = "🔒" + " " + list_name
        }

        lblBlockV.stringValue = (objFocus?.is_block_programe_select ?? false) ? list_name : "-"

        let endValue = (objFocus?.focus_untill_stop ?? false) ? "-" : (objFocus?.end_time ?? Date()).convertToTime()
        lblEndV.stringValue = endValue
    }
    
    func setupSecondData() {
        titleV?.isHidden = true
        lblHours.alignment = .right
        lblBlock.alignment = .right
        lblEnd.alignment = .right

        let objFocus = DBManager.shared.getCurrentBlockList().objFocus
        let objB = DBManager.shared.getCurrentBlockList().objSBl
        let focus_length = Int(objFocus?.used_focus_time ?? 100).secondsToTime()

        var time = ""
        if focus_length.timeInHours != 0 {
            time = "\(focus_length.timeInHours) hrs \(focus_length.timeInMinutes) minutes"
        } else {
            time = "\(focus_length.timeInMinutes) minutes \(focus_length.timeInSeconds) sec"
        }

        lblHoursV.stringValue = time

        var list_name = objB?.name ?? "-"
        if objB?.restart_computer ?? false || objB?.random_character ?? false {
            list_name = "🔒" + " " + list_name
        }

        lblBlockV.stringValue = (objFocus?.is_block_programe_select ?? false) ? list_name : "-"

        let endValue = (objFocus?.focus_untill_stop ?? false) ? "-" : (objFocus?.end_time ?? Date()).convertToTime()
        lblEndV.stringValue = endValue
    }

}
