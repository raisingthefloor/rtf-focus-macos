//
//  BreakTimerManager.swift
//  Focus
//
//  Created by Bhavi on 04/10/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Cocoa
import Foundation

protocol TimerModelIntput {
    func setupInitial()
    func handleTimer()
    func stopTimer()
    func pauseTimer()
}

protocol TimerModelOutput {
}

protocol TimerModelType {
    var input: TimerModelIntput { get }
    var output: TimerModelOutput { get }
    var currentSession: (objFocus: Focuses?, objBl: Block_List?, apps: [Block_Interface], webs: [Block_Interface])? { get set }
    var updateUI: ((_ dialogueType: FocusDialogue, _ hours: Int, _ minutes: Int, _ seconds: Int) -> Void)? { get set }
}

class BreakTimerManager: TimerModelIntput, TimerModelOutput, TimerModelType {
    var updateUI: ((FocusDialogue, Int, Int, Int) -> Void)?

    var currentSession: (objFocus: Focuses?, objBl: Block_List?, apps: [Block_Interface], webs: [Block_Interface])?
    var input: TimerModelIntput { return self }
    var output: TimerModelOutput { return self }

    var isBreaktimerOn: Bool = false
    var remaininTimeInSeconds = 0
    var counter: Int = 0
    var break_stop_after_time: Double = 0
    var breakTimer: Timer?
}

extension BreakTimerManager {
    func setupInitial() {
        currentSession = DBManager.shared.getCurrentBlockList()
        updateCounterValue()
        handleTimer()
    }

    func performValueUpdate(counter: Int) -> (popup: FocusDialogue, hours: Int, minutes: Int, seconds: Int) {
        let hours = (counter / 60) / 60
        let minutes = counter / 60
        let seconds = counter % 60

        switch Double(counter) {
        case 0:
            return (popup: .end_break_alert, hours: hours, minutes: minutes, seconds: seconds)
        default:
            return defaultState(counter: counter)
        }
    }

    // TODO: Need to Set for Hours options

    func defaultState(counter: Int) -> (popup: FocusDialogue, hours: Int, minutes: Int, seconds: Int) {
        let hours = (counter / 60) / 60
        let minutes = counter / 60
        let seconds = counter % 60
        return (popup: .none, hours: hours, minutes: minutes, seconds: seconds)
    }
}

extension BreakTimerManager {
    func handleTimer() {
        updateCounterValue()
        if !isBreaktimerOn {
            if remaininTimeInSeconds == 0 {
                resetTimer()
            }
            startTimer()
            isBreaktimerOn = true
        } else {
            pauseTimer()
            isBreaktimerOn = false
        }
    }

    func updateCounterValue() { // It it used for updating the  UI
        guard let obj = currentSession?.objFocus else { return }
        remaininTimeInSeconds = Int(obj.remaining_break_time)
        let countdownerDetails = remaininTimeInSeconds.secondsToTime()
        updateTimeInfo(hours: countdownerDetails.timeInHours, minutes: countdownerDetails.timeInMinutes, seconds: countdownerDetails.timeInSeconds) // Need to Update the Lables of floating Button
    }

    func startTimer() {
        DispatchQueue.global(qos: .background).async(execute: { () -> Void in
            self.breakTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
            RunLoop.current.add(self.breakTimer!, forMode: .default)
            RunLoop.current.run()
        })
    }

    func pauseTimer() {
        DispatchQueue.main.async {
            self.breakTimer?.invalidate()
            if self.remaininTimeInSeconds > 0 {
            }
        }
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
        guard let obj = currentSession?.objFocus else { return }

        print("remaininTimeInSeconds ::: \(remaininTimeInSeconds)")
        print("Stop after This Min ::: \(Int(obj.remaining_break_time))")

        if remaininTimeInSeconds > 0 {
            remaininTimeInSeconds -= 1
            let countdownerDetails = performValueUpdate(counter: remaininTimeInSeconds)
            if countdownerDetails.popup == .none {
                updateTimeInfo(hours: countdownerDetails.hours, minutes: countdownerDetails.minutes, seconds: countdownerDetails.seconds)
                updateRemaingTimeInDB(seconds: remaininTimeInSeconds)
            } else {
                pauseTimer()
                isBreaktimerOn = false
                updateUI?(countdownerDetails.popup, countdownerDetails.hours, countdownerDetails.minutes, countdownerDetails.seconds)
            }
        } else {
            pauseTimer()
            isBreaktimerOn = false
        }
    }

    func updateTimeInfo(hours: Int, minutes: Int, seconds: Int) {
        updateUI?(.none, hours, minutes, seconds)
    }

    func updateRemaingTimeInDB(seconds: Int) {
        DispatchQueue.main.async {
            guard let obj = self.currentSession?.objFocus else { return }
            obj.remaining_break_time = Double(seconds)
            DBManager.shared.saveContext()
        }
    }
}
