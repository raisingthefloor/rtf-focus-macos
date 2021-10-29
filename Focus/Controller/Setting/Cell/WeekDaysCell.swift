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

class WeekDaysCell: NSTableCellView {
    @IBOutlet var stackView: NSStackView!
    @IBOutlet var btnDay: NSButton!
    @IBOutlet var btnM: NSButton!
    @IBOutlet var btnT: NSButton!
    @IBOutlet var btnW: NSButton!
    @IBOutlet var btnTh: NSButton!
    @IBOutlet var btnF: NSButton!
    @IBOutlet var btnS: NSButton!

    var objFSchedule: Focus_Schedule?
    var refreshTable: ((Bool) -> Void)?

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

    func configDays(obj: Focus_Schedule?) {
        objFSchedule = obj
        let arrDays = objFSchedule?.days_?.allObjects as! [Focus_Schedule_Days]
        var isSelected: Bool = false
        var i = 1
        let isActive = !(objFSchedule?.is_active ?? false)
        let isSetBlock = (obj?.block_list_id != nil)

        stackView.removeSubviews()
        for day in Calendar.current.veryShortWeekdaySymbols {
            let view = NSView(frame: NSRect(x: 0, y: -2, width: 14, height: 18))

            let btn = CustomButton(frame: NSRect(x: 0, y: 0, width: 18, height: 18))

            btn.tag = i
            btn.target = self
            btn.action = #selector(toggleDay(_:))
            if !arrDays.isEmpty {
                isSelected = arrDays.compactMap({ Int($0.day) == i }).filter({ $0 }).first ?? false
            }

            //  btn.state = isSelected ? .on : .off
            btn.font = NSFont.systemFont(ofSize: 10, weight: .regular)
            btn.title = day
            btn.alignment = .center
            btn.corner_radius = btn.frame.height / 2
            btn.buttonColor = (isActive && isSetBlock) ? Color.day_deselected_color : (isSelected ? Color.day_selected_color : .white)
            btn.activeButtonColor = (isActive && isSetBlock) ? Color.day_deselected_color : (isSelected ? Color.day_selected_color : .white)
            btn.textColor = (isActive && isSetBlock) ? .white : (isSelected ? .white : .black)
            btn.borderWidth = 0.5
            btn.borderColor = .black
            btn.isEnabled = (isActive && isSetBlock) ? false : true
            view.addSubview(btn)

            stackView.addArrangedSubview(view)
            i = i + 1
        }
    }

    @objc func toggleDay(_ sender: CustomButton) {
        var arrDay = objFSchedule?.days_?.allObjects as! [Focus_Schedule_Days]
        let tag = sender.tag
        var isSelected = false
        if !arrDay.isEmpty {
            isSelected = arrDay.compactMap({ Int($0.day) == tag }).filter({ $0 }).first ?? false
        }

        if isSelected {
            if let objDay = arrDay.filter({ $0.day == tag }).compactMap({ $0 }).first {
                DBManager.shared.managedContext.delete(objDay)
                DBManager.shared.saveContext()
            }
        } else {
            if !warningToAddThirdSession() {
                let objDay = Focus_Schedule_Days(context: DBManager.shared.managedContext)
                objDay.day = Int16(tag)
                arrDay.append(objDay)
                objFSchedule?.days_ = NSSet(array: arrDay)
            }
        }

        DBManager.shared.saveContext()
        configDays(obj: objFSchedule)
        refreshTable?(true)
    }

    func warningToAddThirdSession() -> Bool {
        if let s_time = objFSchedule?.start_time_, let e_time = objFSchedule?.end_time_, let arrFSD = objFSchedule?.days_?.allObjects as? [Focus_Schedule_Days], let id = objFSchedule?.id {
            let daysV = arrFSD.compactMap({ Int($0.day) })

            if DBManager.shared.checkScheduleSession(s_time: s_time, e_time: e_time, day: daysV, id: id) {
                let presentingCtrl = WindowsManager.getPresentingController()
                let errorDialog = ErrorDialogueViewC(nibName: "ErrorDialogueViewC", bundle: nil)
                errorDialog.errorType = .general_setting_error
                errorDialog.objBl = DBManager.shared.getCurrentBlockList().objBl
                presentingCtrl?.presentAsSheet(errorDialog)
                return true
            }

            return false
        }
        return false
    }
}
