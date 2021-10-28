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

        let time = Date().currentTime()?.uppercased() ?? ""
        let day = Date().currentDateComponent().weekday ?? 1

        print("Time: \(time) ===== Day: \(day)")

        let reminderData = DBManager.shared.checkAvailablReminder(day: day, time: time, type: .reminder)
        if reminderData.0 {
            if let obj = reminderData.1, let id = obj.id {
                displayScheduleReminder(scheduleId: id)
            }
        }

        let reminderSData = DBManager.shared.checkAvailablReminder(day: day, time: time, type: .schedule_focus)
        if reminderSData.0 {
            if let obj = reminderSData.1, let id = obj.id {
                displayScheduleReminder(scheduleId: id)
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
    func displayScheduleReminder(scheduleId: UUID) {
        DispatchQueue.main.async {
            let presentCtrl = WindowsManager.getPresentingController()
            guard let obj = DBManager.shared.getScheduleFocus(id: scheduleId), let objEx = obj.extend_info else { return }
            if objEx.is_extend_long, objEx.is_extend_mid, objEx.is_extend_short, objEx.is_extend_very_short {
                self.resetExtendFlags(objEx: objEx)
                self.redirectToMainMenu()
                return
            }
            let controller = FocusDialogueViewC(nibName: "FocusDialogueViewC", bundle: nil)
            controller.dialogueType = .schedule_reminded_without_blocklist_alert
            controller.viewModel.reminderSchedule = obj
            controller.breakAction = { action, value, valueType in
                self.updateViewnData(dialogueType: .schedule_reminded_without_blocklist_alert, action: action, value: value, valueType: valueType, scheduleId: scheduleId)
            }
            presentCtrl?.presentAsSheet(controller)
        }
    }

    func updateViewnData(dialogueType: FocusDialogue, action: ButtonAction, value: Int, valueType: ButtonValueType, scheduleId: UUID) {
        guard let obj = DBManager.shared.getScheduleFocus(id: scheduleId) else { return }
        switch action {
        case .extend_reminder:
            obj.extend_min_time = Int64(value)
            updateExtendedObject(dialogueType: dialogueType, valueType: valueType, obj: obj)
            DBManager.shared.saveContext()
            // Reminder Extend functionality (Timer)
            guard extendTimer == nil else { return }
            extendTimer = Timer.scheduledTimer(timeInterval: Double(value), target: self, selector: #selector(releaseView), userInfo: scheduleId, repeats: false)
        case .skip_session:
            break
        case .normal_ok:
            redirectToMainMenu()
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
            let presentCtrl = WindowsManager.getPresentingController()

            if presentCtrl is CustomSettingController {
                presentCtrl?.dismiss(nil)
                return
            }

            if presentCtrl is MenuController {
                return
            }

            controller.focusStart = { [weak self] isStarted in
                if isStarted {
                    // self?.setupCountDown() Set there the Observer to start Countdown
                }
            }
            presentCtrl?.presentAsModalWindow(controller)
        }
    }

//    func updateReminder(obj: Focus_Schedule?) {
//        guard let objF = obj, let uuid = objF.id, let id = objF.id?.uuidString, let startTime = objF.start_time else { return }
//        var dateComponents = startTime.toDateComponent()
//        dateComponents.minute = (Date().currentDateComponent().minute ?? 0) + Int(obj?.extend_min_time ?? 15)
//        print("DateComponents : === \(dateComponents)")
//
//        var arrDays = objF.days?.components(separatedBy: ",") ?? []
//        arrDays = arrDays.filter({ $0 != "" }).compactMap({ $0 })
//        if !arrDays.isEmpty {
//            print("Days : === \(arrDays)")
//            let identifiers = arrDays.map({ (id + "_" + $0) })
//            print("identifiers : === \(identifiers)")
//
//            NotificationManager.shared.removePendingNotificationRequests(identifiers: identifiers)
//            for i in arrDays {
//                let identifier = id + "_" + i
//                dateComponents.weekday = Int(i) ?? 0
//                NotificationManager.shared.setLocalNotification(info: LocalNotificationInfo(title: "Focus Reminder", body: "You asked to be reminded to focus at this time.", dateComponents: dateComponents, identifier: identifier, uuid: uuid, repeats: true))
//            }
//        }
//    }

    func resetExtendFlags(objEx: Schedule_Focus_Extend) {
        objEx.is_extend_long = false
        objEx.is_extend_mid = false
        objEx.is_extend_short = false
        objEx.is_extend_very_short = false
        DBManager.shared.saveContext()
    }

    @objc func releaseView() {
        guard extendTimer != nil, let id = extendTimer?.userInfo as? UUID else { return }
        extendTimer?.invalidate()
        extendTimer = nil
        displayScheduleReminder(scheduleId: id)
    }
}
