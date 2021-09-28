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

class FloatingFocusViewC: NSViewController {
    @IBOutlet var btnFocus: CustomButton!
    @IBOutlet var lblTimeVal: NSTextField!

    var addedObserver = false
    var remaininTimeInSeconds = 0
    var countdownTimer: Timer?
    var countdowner: Countdowner?
    var runningTimer = false

    let viewModel: MenuViewModelType = MenuViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
    }
}

extension FloatingFocusViewC: BasicSetupType {
    func setUpText() {
        btnFocus.title = NSLocalizedString("Button.Focus", comment: "Focus")
    }

    func setUpViews() {
        lblTimeVal.font = NSFont.systemFont(ofSize: 13, weight: .bold)
        lblTimeVal.textColor = .black

        // If in GS Coundt down is on then show timer It appears below button else
        // If focus is running then Show "FOCUS"
        // If Break mode is on then Show "BREAK"

        guard let obj = viewModel.input.focusObj else { return }
        if obj.is_focusing {
            btnFocus.buttonColor = Color.very_light_grey
            btnFocus.activeButtonColor = Color.very_light_grey
            btnFocus.textColor = Color.black_color
            btnFocus.borderColor = Color.dark_grey_border
            btnFocus.borderWidth = 0.6
            lblTimeVal.isHidden = false
            setupCountDown()

        } else {
            btnFocus.buttonColor = Color.green_color
            btnFocus.activeButtonColor = Color.green_color
            btnFocus.textColor = .white
        }
    }

    func bindData() {
        btnFocus.target = self
        btnFocus.action = #selector(openMenuViewC)
    }

    @objc func openMenuViewC() {
        guard let obj = viewModel.input.focusObj else { return }

        if obj.is_focusing {
            if let vc = WindowsManager.getVC(withIdentifier: "sidCurrentController", ofType: CurrentSessionVC.self) {
                presentAsModalWindow(vc)
            }
        } else {
            if let controller = WindowsManager.getVC(withIdentifier: "sidMenuController", ofType: MenuController.self) {
                controller.focusStart = { [weak self] _ in
                    self?.setupCountDown()
                }
                presentAsModalWindow(controller)
            }
        }

//        DispatchQueue.main.async {
//            appDelegate?.browserBridge?.stopScript()
//        }
    }
}

extension FloatingFocusViewC {
    func setupCountDown() {
        setDefaultCounterValue()
        countdowner = Countdowner(counter: remaininTimeInSeconds)
        setTime()
        handleTimer()
    }

    func setTime() {
        guard let countdownerDetails = countdowner?.secondsToTime(seconds: remaininTimeInSeconds) else { fatalError() }

        lblTimeVal.stringValue = String(describing: "\(String(format: "%02d", countdownerDetails.timeInMinutes)):\(String(format: "%02d", countdownerDetails.timeInSeconds))")
    }

    func handleTimer() {
        if !runningTimer {
            if remaininTimeInSeconds == 0 {
                resetTimer()
            }
            startTimer()
            runningTimer = true
        } else {
            pauseTimer()
            runningTimer = false
        }
    }

    func setDefaultCounterValue() {
        guard let obj = viewModel.input.focusObj else { return }
        remaininTimeInSeconds = Int(obj.remaining_time)
    }

    func startTimer() {
        DispatchQueue.global(qos: .background).async(execute: { () -> Void in
            self.countdownTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)

            RunLoop.current.add(self.countdownTimer!, forMode: .default)
            RunLoop.current.run()
        })
    }

    func pauseTimer() {
        DispatchQueue.main.async {
            self.countdownTimer?.invalidate()

            if self.remaininTimeInSeconds > 0 {
                // Break Timer On
            }
        }
    }

    func resetTimer() {
        handleTimer()
        setDefaultCounterValue()

        let countdownerDetails = countdowner!.defaultState(counter: remaininTimeInSeconds)

        updateWindow(minutes: countdownerDetails.minutes, seconds: countdownerDetails.seconds)
    }

    @objc func update() {
        guard let obj = viewModel.input.focusObj else { return }

        print("remaininTimeInSeconds ::: \(remaininTimeInSeconds)")

        print("Stop after This Min ::: \(Int(obj.stop_focus_after_time))")
        if remaininTimeInSeconds == Int(obj.stop_focus_after_time) {
            pauseTimer()
            runningTimer = false
            showBreakDialogue()
            return
        } else if remaininTimeInSeconds > 0 {
            remaininTimeInSeconds -= 1
            guard let countdownerDetails = countdowner?.update(counter: remaininTimeInSeconds) else { fatalError() }
            updateWindow(minutes: countdownerDetails.minutes, seconds: countdownerDetails.seconds)
            setCoutdownerTime(seconds: remaininTimeInSeconds)
        } else {
            pauseTimer()
            runningTimer = false
        }
    }

    func updateWindow(minutes: Int, seconds: Int) {
        DispatchQueue.main.async {
            self.lblTimeVal.stringValue = String(describing: "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))")
        }
    }

    @objc func setCoutdownerTime(seconds: Int) {
        DispatchQueue.main.async {
            guard let obj = self.viewModel.input.focusObj else { return }

            obj.remaining_time = Double(seconds)
            self.countdowner?.setCountdownValue(counter: seconds)
            DBManager.shared.saveContext()
        }
    }

    @objc func setTimerValue() {
        setDefaultCounterValue()
        countdowner?.setCountdownValue(counter: remaininTimeInSeconds)
        setTime()
    }
}

extension FloatingFocusViewC {
    func showBreakDialogue() {
        guard let obj = viewModel.input.focusObj else { return }

        // Start Break time timer and also display the Break Time Dialogue
        DispatchQueue.main.async {
            let controller = FocusDialogueViewC(nibName: "FocusDialogueViewC", bundle: nil)
            controller.dialogueType = .short_break_alert
            controller.breakAction = { isAction, value in
                if isAction {
                    obj.stop_focus_after_time = Double(value)
                    DBManager.shared.saveContext()
                    self.handleTimer()
                } else {
                    // Start Break Timer and Break Mode
                }
            }
            self.presentAsSheet(controller)
        }
    }
}
