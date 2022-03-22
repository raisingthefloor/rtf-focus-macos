/*
   Copyright 2020 Raising the Floor - International

   Licensed under the New BSD license. You may not use this file except in
   compliance with this License.

   You may obtain a copy of the License at
   https://github.com/GPII/universal/blob/master/LICENSE.txt

   The R&D leading to these results received funding from the:
 * Rehabilitation Services Administration, US Dept. of Education under
   grant H421A150006 (APCP;
 * National Institute on Disability, Independent Living, and
   Rehabilitation Research (NIDILRR;
 * Administration for Independent Living & Dept. of Education under grants
   H133E080022 (RERC-IT; and H133E130028/90RE5003-01-00 (UIITA-RERC;
 * European Union's Seventh Framework Programme (FP7/2007-2013; grant
   agreement nos. 289016 (Cloud4all; and 610510 (Prosperity4All;
 * William and Flora Hewlett Foundation
 * Ontario Ministry of Research and Innovation
 * Canadian Foundation for Innovation
 * Adobe Foundation
 * Consumer Electronics Association Foundation
 */

import Cocoa
import Foundation

protocol TimerModelIntput {
    func setupInitial()
    func handleTimer()
    func stopTimer()
    func pauseTimer()
    func updateTimerStatus()
    func isTimerAssigned() -> Bool
}

protocol TimerModelOutput {
}

protocol TimerModelType {
    var input: TimerModelIntput { get }
    var output: TimerModelOutput { get }
    var currentSession: (objFocus: Current_Focus?, arrObjBl: [Block_List], apps: [Block_Interface], webs: [Block_Interface])? { get set }
    var updateUI: ((_ dialogueType: FocusDialogue, _ hours: Int, _ minutes: Int, _ seconds: Int, _ focuses: [Focus_List]) -> Void)? { get set }
    var usedTime: Int { get set }
}

class BreakTimerManager: TimerModelIntput, TimerModelOutput, TimerModelType {
    var usedTime: Int = 0

    var updateUI: ((FocusDialogue, Int, Int, Int, [Focus_List]) -> Void)?

    var currentSession: (objFocus: Current_Focus?, arrObjBl: [Block_List], apps: [Block_Interface], webs: [Block_Interface])?
    var input: TimerModelIntput { return self }
    var output: TimerModelOutput { return self }

    var isBreaktimerOn: Bool = false
    var remaininTimeInSeconds = 0
//    var counter: Int = 0
//    var break_stop_after_time: Double = 0
    var breakTimer: Timer?
}

extension BreakTimerManager {
    func setupInitial() {
        currentSession = DBManager.shared.getCurrentBlockList()
        updateCounterValue()
        handleTimer()
    }

    func performValueUpdate(counter: Int) -> (popup: FocusDialogue, hours: Int, minutes: Int, seconds: Int) {
        let conterTime = counter.secondsToTime()
        DispatchQueue.global(qos: .userInteractive).async {
            AppManager.shared.browserBridge?.quitActivityMonitor()
        }
        switch Double(counter) {
        case 0:
            return (popup: .end_break_alert, hours: conterTime.timeInHours, minutes: conterTime.timeInMinutes, seconds: conterTime.timeInSeconds)
        default:
            return (popup: .none, hours: conterTime.timeInHours, minutes: conterTime.timeInMinutes, seconds: conterTime.timeInSeconds)
        }
    }
}

extension BreakTimerManager {
    func updateTimerStatus() {
    }

    func isTimerAssigned() -> Bool {
        return (breakTimer != nil)
    }

    func handleTimer() {
        updateCounterValue()
        if !isBreaktimerOn {
            startTimer()
            isBreaktimerOn = true
        } else {
            pauseTimer()
            isBreaktimerOn = false
        }
    }

    func updateCounterValue() { // It it used for updating the  UI
        guard let obj = currentSession?.objFocus, obj.is_focusing, obj.is_break_time, let arrSession = obj.focuses?.allObjects as? [Focus_List] else { return }
        remaininTimeInSeconds = Int(obj.remaining_break_time)
        let countdownerDetails = remaininTimeInSeconds.secondsToTime()
        updateTimeInfo(hours: countdownerDetails.timeInHours, minutes: countdownerDetails.timeInMinutes, seconds: countdownerDetails.timeInSeconds, arrSession: arrSession) // Need to Update the Lables of floating Button
    }

    func startTimer() {
        DispatchQueue.global(qos: .background).async(execute: { () -> Void in
            self.breakTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
            if self.breakTimer != nil {
                RunLoop.current.add(self.breakTimer!, forMode: .default)
                RunLoop.current.run()
            }
        })
    }

    func pauseTimer() {
        DispatchQueue.global(qos: .background).async(execute: { () -> Void in
            self.breakTimer?.invalidate()
            self.breakTimer = nil
        })
    }

    func resetTimer() {
        handleTimer()
        updateCounterValue()
    }

    func stopTimer() {
        pauseTimer()
        isBreaktimerOn = false
    }

    @objc func update() {
        guard let obj = currentSession?.objFocus, obj.is_break_time, let arrSession = obj.focuses?.allObjects as? [Focus_List] else {
            stopTimer()
            updateUI?(.unknown, 0, 0, 0, [])
            return
        }

//        print("BREAK remaininTimeInSeconds ::: \(remaininTimeInSeconds)")
//        print("BREAK Stop after This Min ::: \(Int(obj.remaining_break_time))")

        if remaininTimeInSeconds > 0 {
            remaininTimeInSeconds -= 1
            let countdownerDetails = performValueUpdate(counter: remaininTimeInSeconds)
            if countdownerDetails.popup == .none {
                updateTimeInfo(hours: countdownerDetails.hours, minutes: countdownerDetails.minutes, seconds: countdownerDetails.seconds, arrSession: arrSession)
                updateRemaingTimeInDB(seconds: remaininTimeInSeconds)
            } else {
                pauseTimer()
                WindowsManager.dismissErrorController()
                isBreaktimerOn = false
                updateUI?(countdownerDetails.popup, countdownerDetails.hours, countdownerDetails.minutes, countdownerDetails.seconds, arrSession)
            }
        } else {
            pauseTimer()
            isBreaktimerOn = false
        }
    }

    func updateTimeInfo(hours: Int, minutes: Int, seconds: Int, arrSession: [Focus_List]) {
        updateUI?(.none, hours, minutes, seconds, arrSession)
    }

    func updateRemaingTimeInDB(seconds: Int) {
        DispatchQueue.main.async {
            guard let obj = self.currentSession?.objFocus else { return }
            obj.remaining_break_time = Double(seconds)
            DBManager.shared.saveContext()
        }
    }
}
