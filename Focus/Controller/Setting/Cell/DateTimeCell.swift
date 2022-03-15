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

class DateTimeCell: NSTableCellView {
    @IBOutlet var datetimePicker: NSDatePicker!

    var objFSchedule: Focus_Schedule?
    var refreshTable: ((Bool) -> Void)?
    var controller: NSViewController?

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
}

extension DateTimeCell: NSDatePickerCellDelegate {
    func configTimeCell(obj: Focus_Schedule?, isStartTime: Bool = true) {
        objFSchedule = obj
        let isActive = objFSchedule?.is_active ?? false
        let isSetBlock = (objFSchedule?.block_list_name != nil)
        let type = Int(objFSchedule?.type ?? 1)

        datetimePicker.tag = isStartTime ? 1 : 2

        if objFSchedule?.block_list_name != nil {
            // comboTime.selectItem(withObjectValue: obj?.start_time)
            datetimePicker.dateValue = isStartTime ? (obj?.start_time_ ?? Date()) : (obj?.end_time_ ?? Date())
        } else {
            datetimePicker.dateValue = Date()
        }
        datetimePicker.delegate = self
        datetimePicker.isEnabled = isSetBlock ? ((isActive && isSetBlock) ? true : false) : false
        datetimePicker.target = self
        datetimePicker.action = #selector(dateSelected)

        let action = NSEvent.EventTypeMask.mouseExited
        datetimePicker.sendAction(on: action)

        if !isStartTime && ScheduleType(rawValue: type) == .reminder {
            datetimePicker.isEnabled = false
        }
    }

    @objc func dateSelected() {
        print("Selected Date : \(datetimePicker.dateValue)")
        if ScheduleViewModel.isRunning(objFS: objFSchedule) {
            displayError(errorType: .focus_schedule_error)
            return
        }
        let datetime = datetimePicker.dateValue.currentTime().date ?? datetimePicker.dateValue

        updateTimeValue(datetimePicker, time: datetime)
    }
}

extension DateTimeCell {
    func updateTimeValue(_ datetimePicker: NSDatePicker, time: Date) {
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

        let type = Int(objFSchedule?.type ?? 1)
        let objGCategory = DBManager.shared.getGeneralCategoryData().gCat?.general_setting

        if datetimePicker.tag == 1 {
            objFSchedule?.start_time = time.convertToScheduleFormateTime()
            objFSchedule?.start_time_ = time.adding(hour: 0, min: 0, sec: 0)

            if ScheduleType(rawValue: type) == .schedule_focus && (objGCategory?.warning_before_schedule_session_start ?? false) {
                objFSchedule?.reminder_date = time.adding(hour: 0, min: -5, sec: 0)
            } else {
                objFSchedule?.reminder_date = time.adding(hour: 0, min: 0, sec: 0)
            }

            if ScheduleType(rawValue: type) == .reminder {
                objFSchedule?.end_time = time.convertToScheduleFormateTime()
                objFSchedule?.end_time_ = time.adding(hour: 0, min: 0, sec: 1)
            }

            print(" time Value :::: \(time.adding(hour: 0, min: 0, sec: 0))")
        } else {
            objFSchedule?.end_time = time.convertToScheduleFormateTime()
            objFSchedule?.end_time_ = time.adding(hour: 0, min: 0, sec: 0)
        }

        let arrFSD = objFSchedule?.days_?.allObjects as! [Focus_Schedule_Days]
        let daysV = arrFSD.compactMap({ Int($0.day) })
        var referesh: Bool = true

        if let s_time = objFSchedule?.start_time_, let e_time = objFSchedule?.end_time_, let id = objFSchedule?.id {
            if s_time > e_time {
                objFSchedule?.end_time = ""
                objFSchedule?.end_time_ = nil
                if datetimePicker.tag == 2 { datetimePicker.dateValue = Date() }

                referesh = false
                displayError(errorType: .validation_error)

            } else {
                if objFSchedule?.end_time == objFSchedule?.start_time && ScheduleType(rawValue: type) == .schedule_focus {
                    resetDateData(errTpe: .validation_error_end_start_time)
                    refreshTable?(true)
                    return
                }
                let result = DBManager.shared.validateScheduleSessionSlotsExsits(s_time: s_time, e_time: e_time, day: daysV, id: id)
                if !result.isValid {
                    resetDateData(errTpe: result.errTpe)
                } else {
                    objFSchedule?.time_interval = findDateDiff(time1: s_time, time2: e_time)
                    DBManager.shared.saveContext()
                }
            }

            refreshTable?(referesh)
        }
    }

    func resetDateData(errTpe: ErrorDialogue) {
        if datetimePicker.tag == 2 {
            datetimePicker.dateValue = Date()
            objFSchedule?.end_time = ""
            objFSchedule?.end_time_ = nil
        } else {
            datetimePicker.dateValue = Date()
            objFSchedule?.start_time = ""
            objFSchedule?.start_time_ = nil
            objFSchedule?.reminder_date = nil
        }
        let arrFSD = objFSchedule?.days_?.allObjects as! [Focus_Schedule_Days]
        for obj in arrFSD {
            DBManager.shared.managedContext.delete(obj)
        }
        DBManager.shared.saveContext()
        displayError(errorType: errTpe)
    }

    func displayError(errorType: ErrorDialogue) {
        let presentingCtrl = WindowsManager.getPresentingController()
        let errorDialog = ErrorDialogueViewC(nibName: "ErrorDialogueViewC", bundle: nil)
        errorDialog.errorType = errorType
//        errorDialog.objBl = DBManager.shared.getCurrentBlockList().arrObjBl.last as? Block_List
        presentingCtrl?.presentAsSheet(errorDialog)
    }

    func findDateDiff(time1: Date, time2: Date) -> Double {
        let interval = time2.timeIntervalSince(time1)
        let hour = interval / 3600
        let minute = interval.truncatingRemainder(dividingBy: 3600) / 60
        let intervalInt = Int(interval)
        print("\(intervalInt < 0 ? "-" : "+") \(Int(hour)) Hours \(Int(minute)) Minutes")
        return interval
    }
}
