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

    var remaininTimeInSeconds = 0
    var usedTime = 0

    var countdownTimer: Timer?
    var countdowner: Countdowner?
    var runningTimer = false

    let viewModel: MenuViewModelType = MenuViewModel()
    var breakTimerModel: TimerModelType = BreakTimerManager()
    var focusTimerModel: TimerModelType = FocusTimerManager()
    var objGCategoey: Block_Category?

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
        if let obj = viewModel.input.focusObj {
            if obj.is_focusing && obj.is_break_time {
                btnFocus.title = NSLocalizedString("Button.Break", comment: "Break")
            }
        }
    }

    func setUpViews() {
        lblTimeVal.font = NSFont.systemFont(ofSize: 13, weight: .bold)
        lblTimeVal.textColor = .black

        // If in GS Coundt down is on then show timer It appears below button else
        // If focus is running then Show "FOCUS"
        // If Break mode is on then Show "BREAK"

        guard let obj = viewModel.input.focusObj else { return }
        if obj.is_focusing {
            setupCountDown()
        } else {
            defaultUI()
        }
    }

    func bindData() {
        btnFocus.target = self
        btnFocus.action = #selector(openMenuViewC)
        setupObserver()
    }

    func updateFocusButton() {
        if let isCountDownOn = objGCategoey?.general_setting?.show_count_down_for_break_start_end {
            lblTimeVal.isHidden = !isCountDownOn
        }
        btnFocus.buttonColor = Color.very_light_grey
        btnFocus.activeButtonColor = Color.very_light_grey
        btnFocus.textColor = Color.black_color
        btnFocus.borderColor = Color.dark_grey_border
        btnFocus.borderWidth = 0.6
        setUpText()
    }

    func defaultUI() {
        lblTimeVal.isHidden = true
        btnFocus.buttonColor = Color.green_color
        btnFocus.activeButtonColor = Color.green_color
        btnFocus.textColor = .white
        setUpText()
    }
}

extension FloatingFocusViewC {
    func setupObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidLaunch(_:)), name: NSNotification.Name(rawValue: "appLaunchNotification_session"), object: nil)
    }

    @objc func openMenuViewC() {
        guard let obj = viewModel.input.focusObj else { return }

        if obj.is_focusing {
            if let controller = WindowsManager.getVC(withIdentifier: "sidCurrentController", ofType: CurrentSessionVC.self) {
                controller.viewModel = viewModel
                controller.updateView = { [weak self] isStopSession, action in
                    if isStopSession {
                        self?.focusTimerModel.input.stopTimer()
                        self?.breakTimerModel.input.stopTimer()
                        self?.updateViewnData(dialogueType: .none, action: action, value: 0, valueType: .none)
                    }
                }
                presentAsModalWindow(controller)
            }
        } else {
            if let controller = WindowsManager.getVC(withIdentifier: "sidMenuController", ofType: MenuController.self) {
                controller.focusStart = { [weak self] isStarted in
                    if isStarted {
                        self?.setupCountDown()
                    }
                }
                presentAsModalWindow(controller)
            }
        }
    }

    func startBlockingAppsWeb() {
        guard let obj = viewModel.input.focusObj else { return }

        AppManager.shared.addObserverToCheckAppLaunch()
        WindowsManager.blockWebSite()
        if obj.is_dnd_mode {
            WindowsManager.runDndCommand(cmd: "on")
        }
    }

    func stopBlockingAppsWeb() {
        WindowsManager.stopBlockWebSite()
        AppManager.shared.removeObserver()
        WindowsManager.runDndCommand(cmd: "off")
    }
}

// TIMER Count Down
extension FloatingFocusViewC {
    func setupCountDown() {
        objGCategoey = DBManager.shared.getGeneralCategoryData().gCat
        updateFocusButton()
        startFocusTimer()
//        updateCounterValue()
//        usedTime = 0
//        countdowner = Countdowner(counter: remaininTimeInSeconds, obj: obj)
//        handleTimer()
        startBlockingAppsWeb()
    }

//    func handleTimer() {
//        if !runningTimer {
//            if remaininTimeInSeconds == 0 {
//                resetTimer()
//            }
//            startTimer()
//            runningTimer = true
//        } else {
//            pauseTimer()
//            runningTimer = false
//        }
//    }
//
//    func updateCounterValue() {
//        guard let obj = viewModel.input.focusObj else { return }
//        remaininTimeInSeconds = Int(obj.remaining_time)
//        let countdownerDetails = remaininTimeInSeconds.secondsToTime()
//        updateTimeInfo(hours: countdownerDetails.timeInHours, minutes: countdownerDetails.timeInMinutes, seconds: countdownerDetails.timeInSeconds)
//    }
//
//    func startTimer() {
//        DispatchQueue.global(qos: .background).async(execute: { () -> Void in
//            self.countdownTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
//            RunLoop.current.add(self.countdownTimer!, forMode: .default)
//            RunLoop.current.run()
//        })
//    }
//
//    func pauseTimer() {
//        DispatchQueue.main.async {
//            self.countdownTimer?.invalidate()
//            if self.remaininTimeInSeconds > 0 {
//            }
//        }
//    }
//
//    func resetTimer() {
//        handleTimer()
//        updateCounterValue()
//    }
//
//    @objc func update() {
//        guard let obj = viewModel.input.focusObj else { return }
//
//        print("Focus remaininTimeInSeconds ::: \(remaininTimeInSeconds)")
//        print("Focus usedTimeSeconds ::: \(usedTime)")
//        print("Focus Stop after This Min ::: \(Int(obj.stop_focus_after_time))")
//
//        if remaininTimeInSeconds <= 0 {
//            pauseTimer()
//            runningTimer = false
//            completeSession()
//            return
//        }
//
//        if remaininTimeInSeconds > 0 {
//            remaininTimeInSeconds -= 1
//            usedTime += 1
//            guard let countdownerDetails = countdowner?.update(counter: remaininTimeInSeconds, usedValue: usedTime) else { fatalError() }
//            if countdownerDetails.popup == .none {
//                updateTimeInfo(hours: countdownerDetails.hours, minutes: countdownerDetails.minutes, seconds: countdownerDetails.seconds)
//                updateRemaingTimeInDB(seconds: remaininTimeInSeconds, usedTime: usedTime)
//            } else {
//                pauseTimer()
//                runningTimer = false
//                showBreakDialogue(dialogueType: countdownerDetails.popup)
//            }
//        } else {
//            pauseTimer()
//            runningTimer = false
//        }
//    }
//
//    func updateTimeInfo(hours: Int, minutes: Int, seconds: Int) {
//        DispatchQueue.main.async {
//            self.lblTimeVal.stringValue = String(describing: "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))")
//        }
//    }
//
//    func updateRemaingTimeInDB(seconds: Int, usedTime: Int) {
//        DispatchQueue.main.async {
//            guard let obj = self.viewModel.input.focusObj else { return }
//            obj.remaining_time = Double(seconds)
//            obj.used_focus_time = Double(usedTime)
//            DBManager.shared.saveContext()
//        }
//    }
}

// MARK: Dialogue Present Methods

extension FloatingFocusViewC {
    @objc func appDidLaunch(_ notification: NSNotification) {
        focusTimerModel.input.stopTimer()
        if let app = notification.object as? NSRunningApplication {
            let controller = BlockAppDialogueViewC(nibName: "BlockAppDialogueViewC", bundle: nil)
            controller.dialogueType = .launch_block_app_alert
            controller.viewModel.application = app
            controller.viewModel.currentSession = DBManager.shared.getCurrentBlockList()
            controller.updateView = { action in
                self.updateViewnData(dialogueType: .launch_block_app_alert, action: action, value: 0, valueType: .none)
            }
            presentAsSheet(controller)
        }
    }

    func showBreakDialogue(dialogueType: FocusDialogue) {
        // Start Break time timer and also display the Break Time Dialogue
        DispatchQueue.main.async {
            if let isFirstMin = self.objGCategoey?.general_setting?.block_screen_first_min_each_break, isFirstMin {
                // Display Screen for one min
                let controller = LockedScreenVC(nibName: "LockedScreenVC", bundle: nil)
                controller.dismiss = { _ in
                    self.openBreakDialouge(dialogueType: dialogueType)
                }
                self.presentAsSheet(controller)
            } else {
                self.openBreakDialouge(dialogueType: dialogueType)
            }
        }
    }

    func openBreakDialouge(dialogueType: FocusDialogue) {
        DispatchQueue.main.async {
            let controller = FocusDialogueViewC(nibName: "FocusDialogueViewC", bundle: nil)
            controller.dialogueType = dialogueType
            controller.viewModel.currentSession = DBManager.shared.getCurrentBlockList()
            controller.breakAction = { action, value, valueType in
                self.updateViewnData(dialogueType: dialogueType, action: action, value: value, valueType: valueType)
            }
            self.presentAsSheet(controller)
        }
    }

    func completeSession() {
        DispatchQueue.main.async {
            let controller = SessionCompleteDialogueViewC(nibName: "SessionCompleteDialogueViewC", bundle: nil)
            controller.dialogueType = .seession_completed_alert
            controller.sessionDone = { action, value in
                self.updateViewnData(dialogueType: .seession_completed_alert, action: action, value: value, valueType: .none) // May be Required
            }
            self.presentAsSheet(controller)
        }
    }

    func updateViewnData(dialogueType: FocusDialogue, action: ButtonAction, value: Int, valueType: ButtonValueType) {
        guard let obj = viewModel.input.focusObj, let objSession = DBManager.shared.getCurrentBlockList().objBl else { return }
        usedTime = 0
        switch action {
        case .extend_focus:
            // Focus Extend Here
            //                    obj.stop_focus_after_time = Double(value)
            obj.extended_focus_time = Double(value)
            let val = obj.remaining_time + Double(value)
            obj.remaining_time = val
            updateExtendedObject(dialogueType: dialogueType, valueType: valueType)
            DBManager.shared.saveContext()
            startBlockingAppsWeb()
        case .extent_break:
            // Break Extend Here
            obj.extended_break_time = Double(value)
            let val = obj.remaining_break_time + Double(value)
            obj.remaining_break_time = val
            updateExtendedObject(dialogueType: dialogueType, valueType: valueType)
            DBManager.shared.saveContext()
            breakTimerModel.input.handleTimer()

        case .stop_session:
            // Prepare the Method in Model to reset the value and set default values
            let objEx = obj.extended_value
            obj.is_focusing = false
            obj.is_break_time = false
            objEx?.is_mid_focus = false
            objEx?.is_small_focus = false
            objEx?.is_long_focus = false
            objEx?.is_mid_break = false
            objEx?.is_small_break = false
            objEx?.is_long_break = false

            DBManager.shared.saveContext()
            stopBlockingAppsWeb()
            defaultUI()
        case .skip_session:
            break
        case .normal_ok:
            updateDataAsPerDialogue(dialogueType: dialogueType, obj: obj, objBl: objSession, value: value, valueType: valueType)
        case .extend_reminder:
            break
        }
    }

    func updateExtendedObject(dialogueType: FocusDialogue, valueType: ButtonValueType) {
        guard let obj = viewModel.input.focusObj, let objEx = obj.extended_value else { return }
        switch dialogueType {
        case .end_break_alert:
            switch valueType {
            case .small: break
            //  objEx.is_small_break = true
            case .mid:
                objEx.is_mid_break = true
            case .long:
                objEx.is_long_break = true
            default: break
            }
        case .short_break_alert, .long_break_alert:
            switch valueType {
            case .small: break
            //  objEx.is_small_focus = true
            case .mid:
                objEx.is_mid_focus = true
            case .long:
                objEx.is_long_focus = true
            default: break
            }
        case .seession_completed_alert: break // Need to check

        default: break
        }
    }

    func updateDataAsPerDialogue(dialogueType: FocusDialogue, obj: Focuses, objBl: Block_List, value: Int, valueType: ButtonValueType) {
        switch dialogueType {
        case .end_break_alert:
            // Break End Here
            obj.is_break_time = false
            obj.remaining_break_time = obj.break_lenght_time
            DBManager.shared.saveContext()
            setUpText()
            focusTimerModel.input.updateTimerStatus()
            startBlockingAppsWeb()
        case .short_break_alert:
            // Break Start Here
            obj.is_break_time = true
            DBManager.shared.saveContext()
            if !objBl.blocked_all_break {
                stopBlockingAppsWeb()
            }
            startBreakTime()
        case .long_break_alert:
            // Long Break Start Here
            obj.is_break_time = true
            if value > 0 {
                obj.extended_break_time = Double(value)
                obj.remaining_break_time = Double(value)
                updateExtendedObject(dialogueType: dialogueType, valueType: valueType)
            }
            DBManager.shared.saveContext()
            if !objBl.blocked_all_break {
                stopBlockingAppsWeb()
            }
            startBreakTime()

        case .seession_completed_alert:
            // Session Complete Here
            // TODO: Define the Reset Focus object with default value
            let objEx = obj.extended_value
            obj.is_focusing = false
            obj.is_break_time = false
            obj.is_focusing = false
            obj.is_break_time = false
            objEx?.is_mid_focus = false
            objEx?.is_small_focus = false
            objEx?.is_long_focus = false
            objEx?.is_mid_break = false
            objEx?.is_small_break = false
            objEx?.is_long_break = false

            DBManager.shared.saveContext()
            stopBlockingAppsWeb()
            defaultUI()
        default:
            setUpText()
            focusTimerModel.input.updateTimerStatus()
        }
    }
}

// MARK: Break Time Section

extension FloatingFocusViewC {
    func startBreakTime() {
        breakTimerModel.input.setupInitial()
        setUpText()
        breakTimerModel.updateUI = { dType, h, m, s in
            if dType == .end_break_alert {
                self.openBreakDialouge(dialogueType: dType)
            }
            self.updateTimeInfo(hours: h, minutes: m, seconds: s)
        }
    }

    func startFocusTimer() {
        focusTimerModel.input.setupInitial()
        setUpText()
        focusTimerModel.updateUI = { dType, h, m, s in
            switch dType {
            case .seession_completed_alert:
                self.completeSession()
            case .none:
                self.updateTimeInfo(hours: h, minutes: m, seconds: s)
            default:
                self.showBreakDialogue(dialogueType: dType)
            }
            // self.updateTimeInfo(hours: h, minutes: m, seconds: s)
        }
    }

    func updateTimeInfo(hours: Int, minutes: Int, seconds: Int) {
        DispatchQueue.main.async {
            self.lblTimeVal.stringValue = String(describing: "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))")
        }
    }
}
