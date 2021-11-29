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
import Foundation

protocol ReminderModelIntput {
    func setupInitial()
    func stopTimer()
    func pauseTimer()
}

protocol ReminderModelOutput {
}

protocol ReminderModelType {
    var input: ReminderModelIntput { get }
    var output: ReminderModelOutput { get }
    var showDialogue: ((_ dialogueType: FocusDialogue) -> Void)? { get set }
}

class ReminderTimerManager: ReminderModelIntput, ReminderModelOutput, ReminderModelType {
    var input: ReminderModelIntput { return self }

    var output: ReminderModelOutput { return self }

    var showDialogue: ((FocusDialogue) -> Void)?
    var reminderTimer: Timer?
    private var extendTimer: Timer?

    func setupInitial() {
        starTimer()
    }
}

extension ReminderTimerManager {
    func starTimer() {
        DispatchQueue.global(qos: .background).async(execute: { () -> Void in
            self.reminderTimer = .scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.checkTodayReminder), userInfo: nil, repeats: true)
            RunLoop.current.add(self.reminderTimer!, forMode: .default)
            RunLoop.current.run()
        })
    }

    // Used for Reminder and Schedule Session
    @objc func checkTodayReminder() {
        // Check If Two session is working then don't check DB for Reminder
        // Check Today's Reminder at current time in DB If data is there then Show Reminder Dialogue.

        let result = Date().currentTime()
        let time = result.strDate?.uppercased() ?? ""
        let datetime = result.date ?? Date()
        let day = Date().currentDateComponent().weekday ?? 1

        print("Time: \(time) ===== Day: \(day)")

        let isMultipleSession = DBManager.shared.getCurrentSession()?.focuses?.allObjects.count > 1

        if !isMultipleSession {
            // Check Schedule Reminder
            let reminderData = DBManager.shared.checkAvailablReminder(day: day, time: time, date: datetime, type: .reminder)
            if reminderData.isPresent {
                if let obj = reminderData.objFS, let id = obj.id {
                    displayScheduleReminder(scheduleId: id, dialogueType: .schedule_reminded_without_blocklist_alert)
                }
            }

            // Check Schedule Session
            let reminderSData = DBManager.shared.checkAvailablReminder(day: day, time: time, date: datetime, type: .schedule_focus)
            if reminderSData.isPresent && reminderSData.objFS?.extend_min_time == 0 {
                if let obj = reminderSData.objFS, let id = obj.id {
                    displayScheduleReminder(scheduleId: id, dialogueType: .schedule_reminded_with_blocklist_alert)
                }
            } else if reminderSData.isPresent {
                createFocus(objFS: reminderSData.objFS)
                // TODO: start Session Here. Entry in focuses table.
            }
        }
    }

    func pauseTimer() {
        DispatchQueue.global(qos: .background).async(execute: { () -> Void in
            self.reminderTimer?.invalidate()
        })
    }

    func stopTimer() {
        pauseTimer()
    }
}

extension ReminderTimerManager {
    func displayScheduleReminder(scheduleId: UUID, dialogueType: FocusDialogue) {
        DispatchQueue.main.async {
            let presentCtrl = WindowsManager.getPresentingController()
            guard let obj = DBManager.shared.getScheduleFocus(id: scheduleId), let objEx = obj.extend_info else { return }
            if objEx.is_extend_long, objEx.is_extend_mid, objEx.is_extend_short, objEx.is_extend_very_short {
                self.resetExtendFlags(objEx: objEx)
                self.redirectToMainMenu()
                return
            }
            let controller = FocusDialogueViewC(nibName: "FocusDialogueViewC", bundle: nil)
            controller.dialogueType = dialogueType
            controller.viewModel.reminderSchedule = obj
            controller.breakAction = { action, value, valueType in
                self.updateViewnData(dialogueType: dialogueType, action: action, value: value, valueType: valueType, scheduleId: scheduleId)
            }
            presentCtrl?.presentAsSheet(controller)
        }
    }

    func updateViewnData(dialogueType: FocusDialogue, action: ButtonAction, value: Int, valueType: ButtonValueType, scheduleId: UUID) {
        guard let obj = DBManager.shared.getScheduleFocus(id: scheduleId) else { return }
        switch action {
        case .extend_reminder:
            if value != 0 {
                obj.extend_min_time = Int64(value)
                updateExtendedObject(dialogueType: dialogueType, valueType: valueType, obj: obj)
                obj.reminder_date = Date().adding(hour: 0, min: value, sec: 0)
                DBManager.shared.saveContext()
            } else {
                createFocus(objFS: obj)
            }
        case .skip_session:
            break
        case .normal_ok:
            if dialogueType == .schedule_reminded_with_blocklist_alert {
                obj.extend_min_time = 5
                obj.reminder_date = obj.start_time_
                DBManager.shared.saveContext()
            } else {
                redirectToMainMenu()
            }
        default: break
        }
    }

    func updateExtendedObject(dialogueType: FocusDialogue, valueType: ButtonValueType, obj: Focus_Schedule) {
        guard let objEx = obj.extend_info else { return }
        switch dialogueType {
        case .schedule_reminded_without_blocklist_alert:
            if !objEx.is_extend_long {
                objEx.is_extend_long = true
            } else if !objEx.is_extend_mid {
                objEx.is_extend_mid = true
            } else if !objEx.is_extend_short {
                objEx.is_extend_short = true
            } else if !objEx.is_extend_very_short {
                objEx.is_extend_very_short = true
            }
        default: break
        }
    }

    func redirectToMainMenu() {
        if let controller = WindowsManager.getVC(withIdentifier: "sidMenuController", ofType: MenuController.self) {
            WindowsManager.dismissController()
            let presentCtrl = WindowsManager.getPresentingController()
            if presentCtrl is MenuController {
                return
            }
            AppManager.shared.stopBothTimer()
            controller.focusStart = { isStarted in
                if isStarted {
                    AppManager.shared.resumeTimer()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: ObserverName.reminder_schedule.rawValue), object: nil)
                }
            }
            presentCtrl?.presentAsModalWindow(controller)
        }
    }

    func resetExtendFlags(objEx: Schedule_Focus_Extend) {
        objEx.is_extend_long = false
        objEx.is_extend_mid = false
        objEx.is_extend_short = false
        objEx.is_extend_very_short = false
        DBManager.shared.saveContext()
    }

    @objc func releaseView() {
        guard extendTimer != nil, let data = extendTimer?.userInfo as? [String: Any], let dType = data["dType"] as? FocusDialogue, let id = data["scheduleId"] as? UUID else { return }
        extendTimer?.invalidate()
        extendTimer = nil
        displayScheduleReminder(scheduleId: id, dialogueType: dType)
    }

    func createFocus(objFS: Focus_Schedule?) {
        guard let objFocus = DBManager.shared.getFoucsObject(), let objSchedule = objFS else { return }
        AppManager.shared.stopBothTimer()

        let objGCategory = DBManager.shared.getGeneralCategoryData().gCat?.general_setting
        let is_short_break_provide = objGCategory?.provide_short_break_schedule_session ?? false
        let break_length = objGCategory?.break_time ?? Focus.BreakTime.five.valueInSeconds
        let focus_stop_length = objGCategory?.for_every_time ?? Focus.FocusTime.fifteen.valueInSeconds
        let objBl = DBManager.shared.getBlockListBy(id: objSchedule.id)
        let endTime = Int(objSchedule.time_interval).secondsToTime()
        let is_untill_stop = objSchedule.time_interval > (3600 * 60)

        var arrFocus: [Focus_List] = objFocus.focuses?.allObjects as? [Focus_List] ?? []

        let obj = Focus_List(context: DBManager.shared.managedContext)
        obj.focus_stop_after_length = focus_stop_length
        obj.break_length_time = break_length
        obj.block_list_id = objSchedule.block_list_id
        obj.is_block_list_dnd = objBl?.is_dnd_category_on ?? false
        obj.is_dnd_mode = obj.is_block_list_dnd
        obj.is_provided_short_break = is_short_break_provide
        obj.is_block_programe_select = true
        obj.focus_untill_stop = is_untill_stop

        obj.created_date = Date()
        obj.focus_id = UUID()
        obj.focus_length_time = objSchedule.time_interval
        obj.session_start_time = Date()
        obj.session_end_time = Date().adding(hour: endTime.timeInHours, min: endTime.timeInMinutes, sec: endTime.timeInSeconds)
        obj.focus_type = Int16(ScheduleType.schedule_focus.rawValue)
        arrFocus.append(obj)

        objFocus.created_date = Date()
        objFocus.focuses = NSSet(array: arrFocus)

        if objFocus.extended_value == nil {
            let objExVal = Focuses_Extended_Value(context: DBManager.shared.managedContext)
            objFocus.extended_value = objExVal
        }

        updateParallelFocusSession(objSchedule: objSchedule, focuslist: arrFocus, objFocus: objFocus)

        DBManager.shared.saveContext()

        AppManager.shared.resumeTimer()
        WindowsManager.dismissController()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ObserverName.reminder_schedule.rawValue), object: nil)
    }

    func updateParallelFocusSession(objSchedule: Focus_Schedule, focuslist: [Focus_List],objFocus: Current_Focus) {

        print("Count focuslist :: \(focuslist.count)")
        let isFocusExsist = focuslist.count == 1
        let total_stop_focus = focuslist.reduce(0) { $0 + $1.focus_stop_after_length }
        let total_break_focus = focuslist.reduce(0) { $0 + $1.break_length_time }
        let total_focus_length = focuslist.reduce(0) { $0 + $1.focus_length_time }
        let is_dnd_mode = focuslist.compactMap({ $0.is_dnd_mode || $0.is_block_list_dnd }).filter({ $0 }).first ?? false
        let is_block_programe_select = focuslist.compactMap({ $0.is_block_programe_select }).filter({ $0 }).first ?? false

        objFocus.combine_focus_length_time = total_focus_length
        objFocus.combine_stop_focus_after_time = total_stop_focus
        objFocus.combine_break_lenght_time = total_break_focus

        print("Remaining Time : \(total_focus_length - objFocus.used_focus_time)")
        objFocus.is_dnd_mode = is_dnd_mode
        objFocus.is_block_programe_select = is_block_programe_select

        objFocus.remaining_focus_time = isFocusExsist ? (total_focus_length - objFocus.used_focus_time) : total_focus_length
        objFocus.remaining_break_time = isFocusExsist ? total_break_focus : total_break_focus
    }
}
