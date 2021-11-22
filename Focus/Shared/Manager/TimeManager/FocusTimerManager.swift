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
    var updateUI: ((FocusDialogue, Int, Int, Int) -> Void)?
    var currentSession: (objFocus: Current_Focus?, arrObjBl: [Block_List?], apps: [Block_Interface], webs: [Block_Interface])?
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
        updateCounterValue()
        handleTimer()
    }
}

extension FocusTimerManager {
    func updateTimerStatus() {
        updateCounterValue()
        handleTimer()
    }

    func handleTimer() {
        updateCounterValue()
        if !isFocustimerOn {
            if remaininFocusTime == 0 {
                resetTimer()
            }
            startTimer()
            isFocustimerOn = true
        } else {
            stopTimer()
        }
    }

    func updateCounterValue() { // It it used for updating the  UI
        guard let obj = currentSession?.objFocus else { return }
        remaininFocusTime = Int(obj.remaining_focus_time)
        used_focus_time = Int(obj.used_focus_time)
        let countdownerDetails = remaininFocusTime.secondsToTime()
        updateTimeInfo(hours: countdownerDetails.timeInHours, minutes: countdownerDetails.timeInMinutes, seconds: countdownerDetails.timeInSeconds)
    }

    func startTimer() {
        DispatchQueue.global(qos: .background).async(execute: { () -> Void in
            self.focusTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
            RunLoop.current.add(self.focusTimer!, forMode: .default)
            RunLoop.current.run()
        })
    }

    func stopTimer() {
        pauseTimer()
        isFocustimerOn = false
    }

    func pauseTimer() {
        DispatchQueue.global(qos: .background).async(execute: { () -> Void in
            self.focusTimer?.invalidate()
            if self.remaininFocusTime > 0 {
            }
        })
    }

    func resetTimer() {
        handleTimer()
        updateCounterValue()
    }

    @objc func update() {
        guard let obj = currentSession?.objFocus else { return }

        print("Focus remaininTimeInSeconds ::: \(remaininFocusTime)")
        print("Focus usedTimeSeconds ::: \(usedTime)")
        print("Focus Stop after This Min ::: \(Int(obj.combine_stop_focus_after_time))")

        if remaininFocusTime <= 0 {
            stopTimer()
            // completeSession()  Open the Complete Session Dialogues
            updateUI?(.seession_completed_alert, 0, 0, 0)
            return
        }

        if remaininFocusTime > 0 {
            remaininFocusTime -= 1
            let countdownerDetails = performValueUpdate(counter: remaininFocusTime, usedValue: usedTime)
            if countdownerDetails.popup == .none {
                updateTimeInfo(hours: countdownerDetails.hours, minutes: countdownerDetails.minutes, seconds: countdownerDetails.seconds)
                updateRemaingTimeInDB(seconds: remaininFocusTime, usedTime: usedTime)
            } else {
                stopTimer()
                WindowsManager.dismissErrorController()
                updateUI?(countdownerDetails.popup, countdownerDetails.hours, countdownerDetails.minutes, countdownerDetails.seconds)
//                showBreakDialogue(dialogueType: countdownerDetails.popup) // Display Break Dialogue
            }
            
            usedTime += 1
            used_focus_time += 1
        } else {
            stopTimer()
        }
    }

    func updateTimeInfo(hours: Int, minutes: Int, seconds: Int) {
        updateUI?(.none, hours, minutes, seconds)
    }

    func updateRemaingTimeInDB(seconds: Int, usedTime: Int) {
        DispatchQueue.main.async {
            guard let obj = self.currentSession?.objFocus else { return }
            obj.remaining_focus_time = Double(seconds)
            obj.used_focus_time = Double(self.used_focus_time)
            obj.decrease_break_time = Double(usedTime)
            DBManager.shared.saveContext()
        }
    }
}

extension FocusTimerManager {
    func performValueUpdate(counter: Int, usedValue: Int) -> (popup: FocusDialogue, hours: Int, minutes: Int, seconds: Int) {
        let hours = (counter / 60) / 60
        let minutes = counter / 60
        let seconds = counter % 60

        switch Double(usedValue) {
        case objFocus.combine_stop_focus_after_time:
            if objFocus.is_provided_short_break {
                let popup: FocusDialogue = (objFocus.focus_untill_stop && !objFocus.is_provided_short_break) ? .long_break_alert : .short_break_alert
                return (popup: popup, hours: hours, minutes: minutes, seconds: seconds)
            } else if objFocus.focus_untill_stop {
                return (popup: .long_break_alert, hours: hours, minutes: minutes, seconds: seconds)
            } else {
                return (popup: .none, hours: hours, minutes: minutes, seconds: seconds)
            }
        default:
            return defaultState(counter: counter)
        }
    }

    func defaultState(counter: Int) -> (popup: FocusDialogue, hours: Int, minutes: Int, seconds: Int) {
        let hours = (counter / 60) / 60
        let minutes = counter / 60
        let seconds = counter % 60
        return (popup: .none, hours: hours, minutes: minutes, seconds: seconds)
    }
}
