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

class ComboBoxCell: NSTableCellView {
    @IBOutlet var popBlocklist: NSPopUpButton!
    @IBOutlet var comboTime: NSComboBox!
    @IBOutlet var statusV: NSView!

    var modelV: DataModelType = DataModel()
    var objFSchedule: Focus_Schedule?
    var refreshTable: ((Bool) -> Void)?
    var controller: NSViewController?

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        setUpText()
        setUpViews()
    }
}

extension ComboBoxCell: BasicSetupType {
    func setUpText() {
    }

    func setUpViews() {
        if popBlocklist != nil {
            popBlocklist.font = NSFont.systemFont(ofSize: 13, weight: .regular)
            popBlocklist.alignment = .left
        }
        if comboTime != nil {
            comboTime.font = NSFont.systemFont(ofSize: 12, weight: .regular)
            comboTime.alignment = .center
        }
    }
}

// Date time  Data Setup
extension ComboBoxCell: NSComboBoxDataSource, NSComboBoxDelegate, NSComboBoxCellDataSource {
    func configStartCell(obj: Focus_Schedule?, arrTimes: [String], isRefresh: Bool = false) {
        objFSchedule = obj
        let is_active = objFSchedule?.is_active ?? false
        if !isRefresh {
            comboTime.removeAllItems()
            comboTime.addItems(withObjectValues: arrTimes)
            if objFSchedule?.block_list_name != nil {
                if let st = obj?.start_time, !st.isEmpty {
                    comboTime.selectItem(withObjectValue: st)
                }
            } else {
                comboTime.stringValue = ""
            }
            comboTime.delegate = self
            comboTime.isEnabled = (objFSchedule?.block_list_name != nil) ? is_active : true
        }
    }

    func configEndCell(obj: Focus_Schedule?, arrTimes: [String], isRefresh: Bool = false) {
        objFSchedule = obj
        let is_active = objFSchedule?.is_active ?? false
        if !isRefresh {
            comboTime.removeAllItems()
            comboTime.addItems(withObjectValues: arrTimes)
            if objFSchedule?.block_list_name != nil {
                comboTime.selectItem(withObjectValue: obj?.end_time)
            } else {
                comboTime.stringValue = ""
            }
            comboTime.delegate = self
            comboTime.isEnabled = (objFSchedule?.block_list_name != nil) ? is_active : true
        }
    }

    func comboBoxSelectionDidChange(_ notification: Notification) {
        if ScheduleViewModel.isRunning(objFS: objFSchedule) {
            displayError(errorType: .focus_schedule_error)
            return
        }

        let comboBox: NSComboBox = (notification.object as? NSComboBox)!
        if !comboBox.objectValues.isEmpty {
            if comboBox.objectValueOfSelectedItem != nil {
                updateTimeValue(comboBox, time: comboBox.objectValueOfSelectedItem as? String)
            }
        }
    }

    func updateTimeValue(_ comboBox: NSComboBox, time: String?) {
        if controller is SchedulerViewC {
            if (controller as! SchedulerViewC).checkSessionRunning(objFS: objFSchedule) {
                let objBl = DBManager.shared.getBlockListBy(id: objFSchedule?.block_list_id)
                (controller as! SchedulerViewC).openErrorDialogue(errorType: .focus_schedule_error, objBL: objBl)
                return
            }
        } else if controller is TodayScheduleViewC {
            if (controller as! TodayScheduleViewC).checkSessionRunning(objFS: objFSchedule) {
                let objBl = DBManager.shared.getBlockListBy(id: objFSchedule?.block_list_id)
                (controller as! TodayScheduleViewC).openErrorDialogue(errorType: .focus_schedule_error, objBL: objBl)
                return
            }
        }

        guard let time = time else { return }
        let type = Int(objFSchedule?.type ?? 1)
        let objGCategory = DBManager.shared.getGeneralCategoryData().gCat?.general_setting

        if comboBox.tag == 1 {
            objFSchedule?.start_time = time
            objFSchedule?.start_time_ = time.toDateTime()

            if ScheduleType(rawValue: type) == .schedule_focus && !(objGCategory?.warning_before_schedule_session_start ?? false) {
                objFSchedule?.reminder_date = time.toDateTime()?.adding(hour: 0, min: -5, sec: 0)
            } else {
                objFSchedule?.reminder_date = time.toDateTime()
            }

        } else {
            objFSchedule?.end_time = time
            objFSchedule?.end_time_ = time.toDateTime()
        }

        let arrFSD = objFSchedule?.days_?.allObjects as! [Focus_Schedule_Days]
        let daysV = arrFSD.compactMap({ Int($0.day) })
        var referesh: Bool = true

        if let s_time = objFSchedule?.start_time_, let e_time = objFSchedule?.end_time_, let id = objFSchedule?.id {
            if s_time > e_time {
                objFSchedule?.end_time = ""
                objFSchedule?.end_time_ = nil
                if comboBox.tag == 2 { comboTime.stringValue = "" }
                configEndCell(obj: objFSchedule, arrTimes: ScheduleViewModel.arrTimes)
                referesh = false
                displayError(errorType: .validation_error)

            } else {
                let result = DBManager.shared.validateScheduleSessionSlotsExsits(s_time: s_time, e_time: e_time, day: daysV, id: id)
                if !result.isValid {
                    if comboBox.tag == 2 {
                        comboTime.stringValue = ""
                        objFSchedule?.end_time = ""
                        objFSchedule?.end_time_ = nil
                        configEndCell(obj: objFSchedule, arrTimes: ScheduleViewModel.arrTimes, isRefresh: true)
                    } else {
                        comboTime.stringValue = ""
                        objFSchedule?.start_time = ""
                        objFSchedule?.start_time_ = nil
                        objFSchedule?.reminder_date = nil
                        configStartCell(obj: objFSchedule, arrTimes: ScheduleViewModel.arrTimes, isRefresh: true)
                    }

                    referesh = false
                    displayError(errorType: result.errTpe)
                    DBManager.shared.saveContext()
                    refreshTable?(referesh)
                    return
                }

                objFSchedule?.time_interval = s_time.findDateDiff(time2: e_time) // findDateDiff(time1: s_time, time2: e_time)
            }
        }

        DBManager.shared.saveContext()
        refreshTable?(referesh)
    }

    func displayError(errorType: ErrorDialogue) {
        let presentingCtrl = WindowsManager.getPresentingController()
        let errorDialog = ErrorDialogueViewC(nibName: "ErrorDialogueViewC", bundle: nil)
        errorDialog.errorType = errorType
//        errorDialog.objBl = DBManager.shared.getCurrentBlockList().arrObjBl.last as? Block_List
        presentingCtrl?.presentAsSheet(errorDialog)
    }
}

// Block list Data Setup
extension ComboBoxCell {
    func configScheduleCell(obj: Focus_Schedule?) {
        objFSchedule = obj

        let color = objFSchedule?.session_color ?? "#DCEFE6"
        let is_active = objFSchedule?.is_active ?? false
        let color_type = ColorType(rawValue: Int(objFSchedule?.color_type ?? 1))

        popBlocklist.removeAllItems()
        popBlocklist.menu = modelV.input.getBlockList(cntrl: .schedule_session).nsMenu
        popBlocklist.target = self
        popBlocklist.action = #selector(handleBlockSelection(_:))
        statusV.border_color = .clear
        statusV.border_width = 2.5

        if objFSchedule?.block_list_name != nil {
            if color_type == .hollow {
                statusV.background_color = Color.list_bg_color
                statusV.border_color = (NSColor(color) ?? Color.light_blue_color)
            } else {
                statusV.background_color = (NSColor(color) ?? NSColor.random)
                statusV.border_color = (NSColor(color) ?? Color.light_blue_color)
            }
        } else {
            statusV.background_color = Color.light_blue_color
            statusV.border_color = Color.light_blue_color
        }

        let lock = (objFSchedule?.has_block_list_stop ?? false) ? "🔒" + " " : ""
        let listname = lock + (objFSchedule?.block_list_name ?? "")

        popBlocklist.selectItem(withTitle: listname)
        popBlocklist.isEnabled = (objFSchedule?.block_list_name != nil) ? is_active : true
    }

    @objc func handleBlockSelection(_ sender: Any) {
        guard sender is NSPopUpButton else { return }
        if ScheduleViewModel.isRunning(objFS: objFSchedule) {
            displayError(errorType: .focus_schedule_error)
            return
        }

        let index = popBlocklist.selectedTag()
        if index == -1 {
            objFSchedule?.block_list_name = ViewCntrl.schedule_session.combolast_option_title
            objFSchedule?.block_list_id = UUID()
            objFSchedule?.type = Int64(ScheduleType.reminder.rawValue)
            objFSchedule?.has_block_list_stop = false
        } else {
            let objBL = modelV.input.getBlockList(cntrl: .schedule_session).blists[index]

            if controller is SchedulerViewC {
                if (controller as! SchedulerViewC).checkSessionRunning(objFS: objFSchedule) {
                    (controller as! SchedulerViewC).openErrorDialogue(errorType: .focus_schedule_error, objBL: objBL)
                    return
                }
            }

            objFSchedule?.block_list_name = objBL.name
            objFSchedule?.block_list_id = objBL.id
            objFSchedule?.type = Int64(ScheduleType.schedule_focus.rawValue)
            objFSchedule?.has_block_list_stop = objBL.stop_focus_session_anytime ? false : true
        }
        objFSchedule?.is_active = true
        DBManager.shared.saveContext()
        refreshTable?(true)
    }
}
