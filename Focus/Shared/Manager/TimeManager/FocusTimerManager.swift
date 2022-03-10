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

class FocusTimerManager: TimerModelIntput, TimerModelOutput, TimerModelType {
    var updateUI: ((FocusDialogue, Int, Int, Int, [Focus_List]) -> Void)?
    var currentSession: (objFocus: Current_Focus?, arrObjBl: [Block_List], apps: [Block_Interface], webs: [Block_Interface])?
    var input: TimerModelIntput { return self }
    var output: TimerModelOutput { return self }
    var usedTime: Int = 0

    var isFocustimerOn: Bool = false
    var remaininFocusTime = 0 // In seconds
    private var used_focus_time: Int = 0
    var stop_focus_after_time: Double = 0
    var focusTimer: Timer?
    var objFocus: Current_Focus!

    func setupInitial() {
        currentSession = DBManager.shared.getCurrentBlockList()
        objFocus = currentSession?.objFocus
        handleTimer()
    }
}

extension FocusTimerManager {
    func isTimerAssigned() -> Bool {
        return (focusTimer != nil)
    }

    func updateTimerStatus() {
        handleTimer()
    }

    func handleTimer() {
        updateCounterValue()
        if !isFocustimerOn {
            startTimer()
            isFocustimerOn = true
        } else {
            stopTimer()
        }
    }

    func updateCounterValue() { // It it used for updating the  UI
        guard let obj = currentSession?.objFocus, obj.is_focusing, !obj.is_break_time, let arrSession = obj.focuses?.allObjects as? [Focus_List] else {
            stopTimer()
            updateUI?(.unknown, 0, 0, 0, [])
            return
        }
        print("updateCounterValue ********************** remaining_focus_time :::::: \(obj.remaining_focus_time)")
        remaininFocusTime = Int(obj.remaining_focus_time)
        print("updateCounterValue ********************** decrease_break_time/usedTime :::::: \(obj.decrease_break_time)")
        used_focus_time = Int(obj.used_focus_time)
        print("updateCounterValue ********************** used_focus_time :::::: \(obj.used_focus_time)")
        usedTime = Int(obj.decrease_break_time) // When app resume then it start from that left time
        let countdownerDetails = remaininFocusTime.secondsToTime()
        print("updateCounterValue ********************** remaininFocusTime{countdownerDetails} :::::: \(countdownerDetails)")

        updateTimeInfo(hours: countdownerDetails.timeInHours, minutes: countdownerDetails.timeInMinutes, seconds: countdownerDetails.timeInSeconds, arrSession: arrSession)
    }

    func startTimer() {
        DispatchQueue.global(qos: .background).async(execute: { () -> Void in
            self.focusTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
            if self.focusTimer != nil {
                RunLoop.current.add(self.focusTimer!, forMode: .default)
                RunLoop.current.run()
            }
        })
    }

    func stopTimer() {
        pauseTimer()
        isFocustimerOn = false
    }

    func pauseTimer() {
        DispatchQueue.global(qos: .background).async(execute: { () -> Void in
            self.focusTimer?.invalidate()
            self.focusTimer = nil
        })
    }

    func resetTimer() {
        handleTimer()
        updateCounterValue()
    }

    @objc func update() {
        guard let obj = currentSession?.objFocus, obj.is_focusing,!obj.is_break_time, let arrSession = obj.focuses?.allObjects as? [Focus_List] else {
            stopTimer()
            updateUI?(.unknown, 0, 0, 0, [])
            return
        }

        print("*** FOCUS *** Total Focus Time : \(Int(obj.combine_focus_length_time)) *** remaininTimeInSeconds ::: \(remaininFocusTime)")
        print("*** FOCUS *** Total Focus Length Time : \(Int(obj.combine_stop_focus_after_time)) *** usedTime ::: \(usedTime)")
        print("*** FOCUS *** Before used_focus_time ::: \(used_focus_time) \n =======  Descrease time \(Int(obj.decrease_break_time))")

        if remaininFocusTime <= 0 {
            stopTimer()
            updateUI?(.seession_completed_alert, 0, 0, 0, arrSession)
            return
        }

        if remaininFocusTime > 0 {
            remaininFocusTime -= 1
            let countdownerDetails = performValueUpdate(counter: remaininFocusTime, usedValue: usedTime)
            var remaing_break_time = Int(objFocus.combine_stop_focus_after_time)
            remaing_break_time = remaing_break_time - usedTime
            let remaing_time = remaing_break_time.secondsToTime()

            if countdownerDetails.popup == .none {
                updateRemaingTimeInDB(seconds: remaininFocusTime, usedTime: usedTime)
                updateTimeInfo(hours: remaing_time.timeInHours, minutes: remaing_time.timeInMinutes, seconds: remaing_time.timeInSeconds, arrSession: arrSession)
            } else {
                stopTimer()
                WindowsManager.dismissErrorController()
                updateUI?(countdownerDetails.popup, remaing_time.timeInHours, remaing_time.timeInMinutes, remaing_time.timeInSeconds, arrSession)
//                showBreakDialogue(dialogueType: countdownerDetails.popup) // Display Break Dialogue
            }
            used_focus_time += 1
            usedTime += 1
        } else {
            stopTimer()
        }
    }

    func updateTimeInfo(hours: Int, minutes: Int, seconds: Int, arrSession: [Focus_List]) {
        updateUI?(.none, hours, minutes, seconds, arrSession)
    }

    func updateRemaingTimeInDB(seconds: Int, usedTime: Int) {
        DispatchQueue.main.async {
            guard let obj = self.currentSession?.objFocus, let arrSession = obj.focuses?.allObjects as? [Focus_List] else { return }
            obj.remaining_focus_time = Double(seconds)
            obj.used_focus_time = Double(self.used_focus_time)
            obj.decrease_break_time = Double(usedTime)
            arrSession.forEach({ $0.used_time = $0.used_time + 1 })

            DBManager.shared.saveContext()
        }
    }
}

extension FocusTimerManager {
    func performValueUpdate(counter: Int, usedValue: Int) -> (popup: FocusDialogue, hours: Int, minutes: Int, seconds: Int) {
        updateSessionData()
        let conterTime = counter.secondsToTime()
//        print("*** FOCUS *** performValueUpdate remaininTimeInSeconds ::: \(counter) == \(conterTime)")
//        print("*** FOCUS *** performValueUpdate usedTimeSeconds ::: \(usedValue) =======  \(objFocus.combine_stop_focus_after_time)")
//        print("*** FOCUS *** performValueUpdate used_focus_time ::: \(used_focus_time) =======  \(objFocus.combine_stop_focus_after_time)")
//        print("*** FOCUS *** performValueUpdate decrease_break_time :::=======  Descrease time \(Int(objFocus.decrease_break_time))")

        switch Double(usedValue) {
        case objFocus.combine_stop_focus_after_time:
            objFocus.decrease_break_time = 0
            
            if objFocus.is_provided_short_break {
                let popup: FocusDialogue = (objFocus.focus_untill_stop && !objFocus.is_provided_short_break) ? .long_break_alert : .short_break_alert
                return (popup: popup, hours: conterTime.timeInHours, minutes: conterTime.timeInMinutes, seconds: conterTime.timeInSeconds)
            } else if objFocus.focus_untill_stop {
                return (popup: .long_break_alert, hours: conterTime.timeInHours, minutes: conterTime.timeInMinutes, seconds: conterTime.timeInSeconds)
            } else {
                return (popup: .none, hours: conterTime.timeInHours, minutes: conterTime.timeInMinutes, seconds: conterTime.timeInSeconds)
            }
        default:
//            print("*** FOCUS ***  Count Down Value ::::: \(conterTime) *** FOCUS ***  ")
            return (popup: .none, hours: conterTime.timeInHours, minutes: conterTime.timeInMinutes, seconds: conterTime.timeInSeconds)
        }
    }

    func updateSessionData() {
        guard var arrSession = objFocus.focuses?.allObjects as? [Focus_List], arrSession.count >= 2 else {
            return
        }
        arrSession = arrSession.sorted(by: { $0.created_date ?? Date() < $1.created_date ?? Date() })
        arrSession.forEach({
            print("*** FOCUS ***  $0.session_end_time ::::: \($0.session_end_time) current date : \(Date())")
            let session_end_date = $0.session_end_time ?? Date()

//            print("*** FOCUS ***  $0.session_end_time Equal Date \(session_end_date.isEqualTo(Date()))")
//            print("*** FOCUS ***  $0.session_end_time Greater Date \(session_end_date.isGreaterThan(Date()))")
//            print("*** FOCUS ***  $0.session_end_time Lessthan Date \(session_end_date.isSmallerThan(Date()))")

            if session_end_date.isEqualTo(Date()) {
                print("*** FOCUS Second Session End ***")
                self.stopTimer()
                DBManager.shared.updateRunningSession(focus: $0)
                self.updateTimerStatus()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ObserverName.update_current_session_ui.rawValue), object: nil)
            }
        })
    }
}
