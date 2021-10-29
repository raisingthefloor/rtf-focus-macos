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
    var arrTimes: [String] = []
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
    func configStartCell(obj: Focus_Schedule?, arrTimes: [String]) {
        self.arrTimes = arrTimes
        objFSchedule = obj
        let is_active = objFSchedule?.is_active ?? false

        comboTime.removeAllItems()
        comboTime.addItems(withObjectValues: arrTimes)
        comboTime.tag = 1
        if objFSchedule?.block_list_name != nil {
            comboTime.selectItem(withObjectValue: obj?.start_time)
        } else {
            comboTime.stringValue = ""
        }
        comboTime.delegate = self
        comboTime.isEnabled = (objFSchedule?.block_list_name != nil) ? is_active : true
    }

    func configEndCell(obj: Focus_Schedule?, arrTimes: [String]) {
        self.arrTimes = arrTimes
        objFSchedule = obj
        let is_active = objFSchedule?.is_active ?? false

        comboTime.removeAllItems()
        comboTime.addItems(withObjectValues: arrTimes)
        comboTime.tag = 2
        if objFSchedule?.block_list_name != nil {
            comboTime.selectItem(withObjectValue: obj?.end_time)
        } else {
            comboTime.stringValue = ""
        }
        comboTime.delegate = self
        comboTime.isEnabled = (objFSchedule?.block_list_name != nil) ? is_active : true
    }

    func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
        print(" Combobox ::::  \(string)")
        for time in arrTimes {
            // substring must have less characters then stings to search
            if string.count < arrTimes.count {
                // only use first part of the strings in the list with length of the search string
                let statePartialStr = time.lowercased()[time.lowercased().startIndex ..< time.lowercased().index(time.lowercased().startIndex, offsetBy: string.count)]
                if statePartialStr.range(of: string.lowercased()) != nil {
                    print("NSComboBox, completedString string")
                    updateTimeValue(comboBox, time: time)
                    return time
                }
            }
        }
        return ""
    }

    func comboBoxSelectionDidChange(_ notification: Notification) {
        let comboBox: NSComboBox = (notification.object as? NSComboBox)!
        updateTimeValue(comboBox, time: comboBox.objectValueOfSelectedItem as? String)
    }

    func updateTimeValue(_ comboBox: NSComboBox, time: String?) {
        guard let time = time else { return }

        if comboBox.tag == 1 {
            objFSchedule?.start_time = time
            objFSchedule?.start_time_ = time.toDateTime()
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
                configEndCell(obj: objFSchedule, arrTimes: arrTimes)
                referesh = false
                displayError()

            } else if DBManager.shared.checkScheduleSession(s_time: s_time, e_time: e_time, day: daysV, id: id) {
                if comboBox.tag == 2 {
                    comboTime.stringValue = ""
                    objFSchedule?.end_time = ""
                    objFSchedule?.end_time_ = nil

                    configEndCell(obj: objFSchedule, arrTimes: arrTimes)
                } else {
                    comboTime.stringValue = ""
                    objFSchedule?.start_time = ""
                    objFSchedule?.start_time_ = nil

                    configStartCell(obj: objFSchedule, arrTimes: arrTimes)
                }

                referesh = false
                displayError()
            }
        }

        DBManager.shared.saveContext()
        refreshTable?(referesh)
    }

    func displayError() {
        let presentingCtrl = WindowsManager.getPresentingController()
        let errorDialog = ErrorDialogueViewC(nibName: "ErrorDialogueViewC", bundle: nil)
        errorDialog.errorType = .general_setting_error
        errorDialog.objBl = DBManager.shared.getCurrentBlockList().objBl
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
        popBlocklist.menu = modelV.input.getBlockList(cntrl: .schedule_session).0
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
        let index = popBlocklist.selectedTag()
        if index == -1 {
            objFSchedule?.block_list_name = ViewCntrl.schedule_session.combolast_option_title
            objFSchedule?.block_list_id = UUID()
            objFSchedule?.type = Int64(ScheduleType.reminder.rawValue)
            objFSchedule?.has_block_list_stop = false
        } else {
            objFSchedule?.block_list_name = modelV.input.getBlockList(cntrl: .schedule_session).1[index].name
            objFSchedule?.block_list_id = modelV.input.getBlockList(cntrl: .schedule_session).1[index].id
            objFSchedule?.type = Int64(ScheduleType.schedule_focus.rawValue)
            objFSchedule?.has_block_list_stop = modelV.input.getBlockList(cntrl: .schedule_session).1[index].stop_focus_session_anytime ? false : true
        }
        objFSchedule?.is_active = true
        DBManager.shared.saveContext()
        refreshTable?(true)
    }

    func findDateDiff(time1Str: String, time2Str: String) -> (interval: Double, startT: Date, endT: Date) {
        let timeformatter = DateFormatter()
        timeformatter.dateFormat = "h a"

        guard let time1 = timeformatter.date(from: time1Str),
              let time2 = timeformatter.date(from: time2Str) else { return (0, Date(), Date()) }

        let interval = time2.timeIntervalSince(time1)
        let hour = interval / 3600
        let minute = interval.truncatingRemainder(dividingBy: 3600) / 60
        let intervalInt = Int(interval)
        print("\(intervalInt < 0 ? "-" : "+") \(Int(hour)) Hours \(Int(minute)) Minutes")
        return (interval, time1, time2)
    }
}
