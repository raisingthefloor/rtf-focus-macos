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

    let viewModel: MenuViewModelType = MenuViewModel() // TODO: Need to update
//    var breakTimerModel: TimerModelType = BreakTimerManager()
//    var focusTimerModel: TimerModelType = FocusTimerManager()
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
        btnFocus.font = NSFont.systemFont(ofSize: 14, weight: .bold)

        // If in GS Coundt down is on then show timer It appears below button else
        // If focus is running then Show "FOCUS"
        // If Break mode is on then Show "BREAK"

        NotificationCenter.default.addObserver(self, selector: #selector(reminderObserver), name: NSNotification.Name(ObserverName.reminder_schedule.rawValue), object: nil)

        guard let obj = viewModel.input.focusObj else { return }
        if obj.is_focusing {
            setupCountDown()
        } else {
            defaultUI()
        }
    }

    func bindData() {
        btnFocus.target = self
        btnFocus.action = #selector(openMenuNCurrentSessionViewC)
        setupObserver()
    }

    func updateFocusButton() {
        btnFocus.buttonColor = Color.very_light_grey
        btnFocus.activeButtonColor = Color.very_light_grey
        btnFocus.textColor = Color.black_color
        btnFocus.borderColor = Color.dark_grey_border
        btnFocus.borderWidth = 0.6
        udateButtonSting(timeVal: "")
    }

    func udateButtonSting(timeVal: String) {
        var time = ""
        if let obj = viewModel.input.focusObj, obj.is_focusing {
            if let isCountDownOn = objGCategoey?.general_setting?.show_count_down_for_break_start_end, isCountDownOn {
                time = (obj.focus_untill_stop && !obj.is_provided_short_break) ? "" : ("\n" + timeVal)
            }
            btnFocus.title = NSLocalizedString("Button.Focus", comment: "Focus") + time
            if obj.is_focusing && obj.is_break_time {
                btnFocus.title = NSLocalizedString("Button.Break", comment: "Break") + time
            }
        } else {
            btnFocus.title = NSLocalizedString("Button.Focus", comment: "Focus")
        }
    }

    func defaultUI() {
        lblTimeVal.isHidden = true
        btnFocus.buttonColor = Color.green_color
        btnFocus.activeButtonColor = Color.green_color
        btnFocus.textColor = .white
        udateButtonSting(timeVal: "")
    }

    @objc func reminderObserver() {
        guard let obj = viewModel.input.focusObj else { return }
        if !obj.is_focusing {
            setupCountDown()
        } else if !AppManager.shared.focusTimerModel.input.isTimerAssigned() {
            setupCountDown()
        } else {
            AppManager.shared.resumeTimer()
        }
    }
}

extension FloatingFocusViewC {
    func setupObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidLaunch(_:)), name: NSNotification.Name(rawValue: ObserverName.appLaunch_event.rawValue), object: nil)
    }

    @objc func openMenuNCurrentSessionViewC() {
        guard let obj = viewModel.input.focusObj else { return }

        if obj.is_focusing {
            if let controller = WindowsManager.getVC(withIdentifier: "sidCurrentController", ofType: CurrentSessionVC.self) {
                controller.viewModel = viewModel
                controller.updateView = { [weak self] isStopSession, action in
                    if isStopSession {
                        AppManager.shared.focusTimerModel.input.stopTimer()
                        AppManager.shared.breakTimerModel.input.stopTimer()
                        if action != .initiate_new_session {
                            self?.updateViewnData(dialogueType: .none, action: action, value: 0, valueType: .none)
                        }
                    } else {
                        if action == .started_new_session || action == .cancel_new_session {
                            guard let objCurrent = self?.viewModel.input.focusObj else { return }
                            // TODO: Update end time with waiting time length (Need to chck possibility)
                            if objCurrent.is_block_programe_select {
                                AppManager.shared.addObserverToCheckAppLaunch()
                                WindowsManager.blockWebSite()
                            }

                            if objCurrent.is_dnd_mode {
                                WindowsManager.runDndCommand(cmd: "on")
                            }

                            if objCurrent.is_break_time {
                                AppManager.shared.breakTimerModel.input.updateTimerStatus()
                            } else {
                                AppManager.shared.focusTimerModel.input.updateTimerStatus()
                            }
                        }
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

        if obj.is_block_programe_select {
            AppManager.shared.addObserverToCheckAppLaunch()
            WindowsManager.blockWebSite()
        }

        if obj.is_dnd_mode {
            WindowsManager.runDndCommand(cmd: "on")
        }
    }

    func stopBlockingAppsWeb(isRestart: Bool, dialogueType: FocusDialogue) {
        if dialogueType != .disincentive_signout_signin_alert {
            AppManager.shared.stopScriptObserver()
        }

        if isRestart {
            if dialogueType == .disincentive_signout_signin_alert {
                WindowsManager.openSystemLogoutDialog()
            }
        }
    }
}

// TIMER Count Down
extension FloatingFocusViewC {
    func setupCountDown() {
        objGCategoey = DBManager.shared.getGeneralCategoryData().gCat
        updateFocusButton()
        startFocusTimer()
        startBlockingAppsWeb()
    }
}

// MARK: Dialogue Present Methods

extension FloatingFocusViewC {
    @objc func appDidLaunch(_ notification: NSNotification) {
        if WindowsManager.isBlockAppDialogueVCOpen() {
            return
        }

        if let app = notification.object as? NSRunningApplication {
            Config.start_date_time = Date()
            AppManager.shared.focusTimerModel.input.stopTimer()
            let presentingCtrl = WindowsManager.getPresentingController()
            let controller = BlockAppDialogueViewC(nibName: "BlockAppDialogueViewC", bundle: nil)
            controller.dialogueType = .launch_block_app_alert
            controller.viewModel.application = app
            controller.viewModel.currentSession = DBManager.shared.getCurrentBlockList()
            controller.updateView = { action in
                self.updateViewnData(dialogueType: .launch_block_app_alert, action: action, value: 0, valueType: .none)
            }
            presentingCtrl?.presentAsSheet(controller)
        }
    }

    func showBreakDialogue(dialogueType: FocusDialogue, callback: @escaping ((Bool) -> Void)) {
        // Start Break time timer and also display the Break Time Dialogue
        DispatchQueue.main.async {
            if let isFirstMin = self.objGCategoey?.general_setting?.block_screen_first_min_each_break, isFirstMin {
                // Display Screen for one min
                let presentingCtrl = WindowsManager.getPresentingController()
                let controller = LockedScreenVC(nibName: "LockedScreenVC", bundle: nil)
                controller.dismiss = { _ in
                    callback(true)
                }
                presentingCtrl?.presentAsSheet(controller)
            } else {
                callback(true)
            }
        }
    }

    func openBreakDialouge(dialogueType: FocusDialogue) {
        DispatchQueue.main.async {
            Config.start_date_time = Date()
            let presentingCtrl = WindowsManager.getPresentingController()
            let controller = FocusDialogueViewC(nibName: "FocusDialogueViewC", bundle: nil)
            controller.dialogueType = dialogueType
            controller.viewModel.currentSession = DBManager.shared.getCurrentBlockList()
            controller.breakAction = { action, value, valueType in
                if action == .normal_ok && (dialogueType == .short_break_alert || dialogueType == .long_break_alert) {
                    self.showBreakDialogue(dialogueType: dialogueType) { isDismiss in
                        if isDismiss {
                            self.updateViewnData(dialogueType: dialogueType, action: action, value: value, valueType: valueType)
                        }
                    }
                } else {
                    self.updateViewnData(dialogueType: dialogueType, action: action, value: value, valueType: valueType)
                }
            }
            presentingCtrl?.presentAsSheet(controller)
        }
    }

    func completeSession() {
        DispatchQueue.main.async {
            let presentingCtrl = WindowsManager.getPresentingController()
            let controller = SessionCompleteDialogueViewC(nibName: "SessionCompleteDialogueViewC", bundle: nil)
            controller.dialogueType = .seession_completed_alert
            controller.sessionDone = { action, value, valueType in
                self.updateViewnData(dialogueType: .seession_completed_alert, action: action, value: value, valueType: valueType)
            }
            presentingCtrl?.presentAsSheet(controller)
        }
    }

    func updateViewnData(dialogueType: FocusDialogue, action: ButtonAction, value: Int, valueType: ButtonValueType) {
        guard let obj = viewModel.input.focusObj, let arrSessions = obj.focuses?.allObjects as? [Focus_List] else { return }

        var objBl: Block_List?
        if let objCF = arrSessions.filter({ $0.is_stop_constraint }).compactMap({ $0 }).first, let id = objCF.block_list_id {
            objBl = DBManager.shared.getBlockListBy(id: id, isRestart: true)
        } else {
            let objCF = arrSessions.compactMap({ $0 }).first
            if let id = objCF?.block_list_id {
                objBl = DBManager.shared.getBlockListBy(id: id, isRestart: false)
            }
        }
        let isRestart = objBl?.restart_computer ?? false

        switch action {
        case .extend_focus:
            AppManager.shared.focusTimerModel.usedTime = 0
            // Focus Extend Here
            obj.extended_focus_time = Double(value)
            obj.combine_stop_focus_after_time = Double(value) // Whatever value set after that min break alert will comes
            let val = obj.remaining_focus_time + Double(value)
            obj.remaining_focus_time = val

            let waiting_time = Config.start_date_time?.findDateDiff(time2: Date()) ?? 0
            print("***** Extend Focus WAITING TIME *****   \(waiting_time)")
            let total_extend_time = Int(value) + Int(waiting_time)
            MenuViewModel.updateExtendEndSessionTime(obj: obj, time: total_extend_time)

            updateExtendedObject(dialogueType: dialogueType, valueType: valueType)
            DBManager.shared.saveContext()
            startBlockingAppsWeb()
            AppManager.shared.focusTimerModel.input.updateTimerStatus()
        case .extent_break:
            AppManager.shared.focusTimerModel.usedTime = 0
            // Break Extend Here
            obj.extended_break_time = Double(value)
            let val = obj.remaining_break_time + Double(value)
            obj.remaining_break_time = val

            let waiting_time = Config.start_date_time?.findDateDiff(time2: Date()) ?? 0
            print("***** Extend Berak WAITING TIME *****   \(waiting_time)")
            let total_extend_time = Int(value) + Int(waiting_time)
            MenuViewModel.updateExtendEndSessionTime(obj: obj, time: total_extend_time)

            updateExtendedObject(dialogueType: dialogueType, valueType: valueType)
            DBManager.shared.saveContext()
            AppManager.shared.breakTimerModel.input.handleTimer()

        case .stop_session:
            AppManager.shared.focusTimerModel.usedTime = 0
            AppManager.shared.resetFocusSession()
            stopBlockingAppsWeb(isRestart: isRestart, dialogueType: dialogueType)
            WindowsManager.dismissController()
            defaultUI()
        case .normal_ok:
            if dialogueType == .long_break_alert || dialogueType == .short_break_alert {
                AppManager.shared.focusTimerModel.usedTime = 0

                let waiting_time = Config.start_date_time?.findDateDiff(time2: Date()) ?? 0
                print("***** IF \(dialogueType.title)  WAITING TIME *****   \(waiting_time)")
                let total_extend_time = Int(waiting_time)
                MenuViewModel.updateExtendEndSessionTime(obj: obj, time: total_extend_time)

            } else if dialogueType == .end_break_alert {
                updateEndSessionTime(obj: obj) // Cause in every break end need add the  break length and block screen time in focus end time/
            } else {
                let waiting_time = Config.start_date_time?.findDateDiff(time2: Date()) ?? 0
                print("***** ELSE \(dialogueType.title)  WAITING TIME *****   \(waiting_time)")
                let total_extend_time = Int(waiting_time)
                MenuViewModel.updateExtendEndSessionTime(obj: obj, time: total_extend_time)
            }
            updateDataAsPerDialogue(dialogueType: dialogueType, obj: obj, objBl: objBl, value: value, valueType: valueType)
        case .extend_reminder, .initiate_new_session, .started_new_session, .cancel_new_session, .skip_session:
            break
        }
    }

    func updateExtendedObject(dialogueType: FocusDialogue, valueType: ButtonValueType) {
        guard let obj = viewModel.input.focusObj, let objEx = obj.extended_value else { return }
        switch dialogueType {
        case .end_break_alert:
            switch valueType {
            case .small:
                objEx.is_small_break = true
            case .mid:
                objEx.is_mid_break = true
            case .long:
                objEx.is_long_break = true
            default: break
            }
        case .short_break_alert, .long_break_alert:
            switch valueType {
            case .small:
                objEx.is_small_focus = true
            case .mid:
                objEx.is_mid_focus = true
            case .long:
                objEx.is_long_focus = true
            default: break
            }
        case .seession_completed_alert:
            switch valueType {
            case .small:
                objEx.is_small_done_focus = true
            case .mid:
                objEx.is_mid_done_focus = true
            case .long:
                objEx.is_long_done_focus = true
            default: break
            }

        default: break
        }
    }

    func updateDataAsPerDialogue(dialogueType: FocusDialogue, obj: Current_Focus, objBl: Block_List?, value: Int, valueType: ButtonValueType) {
        let isRestart = objBl?.restart_computer ?? false

        switch dialogueType {
        case .end_break_alert:
            // Break End Here
            let focuslist = obj.focuses?.allObjects as? [Focus_List]
            let total_stop_focus = focuslist?.reduce(0) { $0 + $1.focus_stop_after_length } ?? 0
            let total_break_focus = focuslist?.reduce(0) { $0 + $1.break_length_time } ?? 0

            obj.is_break_time = false
            obj.remaining_break_time = total_break_focus
            obj.combine_stop_focus_after_time = total_stop_focus
            DBManager.shared.saveContext()
            setUpText()
            AppManager.shared.focusTimerModel.input.updateTimerStatus()
            startBlockingAppsWeb()
        case .short_break_alert:
            // Break Start Here
            obj.is_break_time = true
            DBManager.shared.saveContext()
            if !(objBl?.blocked_all_break ?? false) {
                stopBlockingAppsWeb(isRestart: false, dialogueType: dialogueType)
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
            if !(objBl?.blocked_all_break ?? false) {
                stopBlockingAppsWeb(isRestart: false, dialogueType: dialogueType)
            }
            startBreakTime()

        case .seession_completed_alert:
            // Session Complete Heres
            AppManager.shared.resetFocusSession()
            stopBlockingAppsWeb(isRestart: isRestart, dialogueType: dialogueType)
            WindowsManager.dismissController()
            defaultUI()
        default:
            setUpText()
            AppManager.shared.focusTimerModel.input.updateTimerStatus()
        }
    }
}

// MARK: Focus and Break Time Section

extension FloatingFocusViewC {
    func startBreakTime() {
        AppManager.shared.breakTimerModel.input.setupInitial()
        setUpText()
        AppManager.shared.breakTimerModel.updateUI = { dType, h, m, s, _ in
            if dType == .end_break_alert {
                self.openBreakDialouge(dialogueType: dType)
            } else if dType == .unknown {
                AppManager.shared.resetFocusSession()
                self.stopBlockingAppsWeb(isRestart: true, dialogueType: dType)
                WindowsManager.dismissController()
                self.defaultUI()
                return
            }
            self.updateTimeInfo(hours: h, minutes: m, seconds: s)
        }
    }

    func startFocusTimer() {
        let obj = viewModel.input.focusObj
        let objEx = obj?.extended_value

        AppManager.shared.focusTimerModel.input.setupInitial()
        setUpText()

        if (obj?.is_focusing ?? false) && (obj?.is_break_time ?? false) {
            AppManager.shared.focusTimerModel.input.stopTimer()
            startBreakTime()
        }

        AppManager.shared.focusTimerModel.updateUI = { dType, h, m, s, _ in
            switch dType {
            case .unknown:
                AppManager.shared.resetFocusSession()
                self.stopBlockingAppsWeb(isRestart: true, dialogueType: dType)
                WindowsManager.dismissController()
                self.defaultUI()
            case .seession_completed_alert:
                obj?.is_provided_short_break = false
                DBManager.shared.saveContext()
                self.completeSession()
            case .none:
                self.updateTimeInfo(hours: h, minutes: m, seconds: s)
            case .end_break_alert:
                guard let long = objEx?.is_long_break, long, let mid = objEx?.is_mid_break, mid, let small = objEx?.is_small_break, small else {
                    self.openBreakDialouge(dialogueType: dType)
                    return
                }
            case .short_break_alert, .long_break_alert:
                guard let long = objEx?.is_long_focus, long, let mid = objEx?.is_mid_focus, mid, let small = objEx?.is_small_focus, small else {
                    self.openBreakDialouge(dialogueType: dType)
                    return
                }
            default:
                self.openBreakDialouge(dialogueType: dType)
            }
        }
    }

    func updateTimeInfo(hours: Int, minutes: Int, seconds: Int) {
        let objFocus = viewModel.input.focusObj
        var remaing_break_time = Int(objFocus?.combine_stop_focus_after_time ?? 100)
        remaing_break_time = (objFocus?.is_break_time ?? false) ? Int(objFocus?.remaining_break_time ?? 100) : (remaing_break_time - Int(objFocus?.decrease_break_time ?? 0))

        let break_time = (objFocus?.is_break_time ?? false) ? remaing_break_time.secondsToTime() : remaing_break_time.secondsToTime()

        var time = ""
        if break_time.timeInHours != 0 {
            time = String(describing: "\(String(format: "%02d", break_time.timeInHours)):\(String(format: "%02d", break_time.timeInMinutes))")
        } else {
            time = String(describing: "\(String(format: "%02d", break_time.timeInMinutes)):\(String(format: "%02d", break_time.timeInSeconds))")
        }

        DispatchQueue.main.async {
//            let timeVal = String(describing: "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))")
            self.udateButtonSting(timeVal: time)
        }
    }

    func updateEndSessionTime(obj: Current_Focus?) {
        let objGCategoey = DBManager.shared.getGeneralCategoryData().gCat
        var firstmin_val: Int = 0
        if let isFirstMin = objGCategoey?.general_setting?.block_screen_first_min_each_break, isFirstMin {
            firstmin_val = 1 * 60 // one min
        }

        let waiting_time = Config.start_date_time?.findDateDiff(time2: Date()) ?? 0
        print("***** End Break WAITING TIME *****   \(waiting_time)")

        let arrSessions = obj?.focuses?.allObjects as? [Focus_List]

        arrSessions?.forEach({
            let extend_time = (Int($0.break_length_time) + firstmin_val + Int(waiting_time)).secondsToTime()
            $0.session_end_time = $0.session_end_time?.adding(hour: extend_time.timeInHours, min: extend_time.timeInMinutes, sec: extend_time.timeInSeconds)
        })
        Config.start_date_time = nil
    }
}

extension FloatingFocusViewC {
    // Allow the window to still be dragged from this button
    override func mouseDown(with mouseDownEvent: NSEvent) {
        guard let window = view.window else { return }
        let startingPoint = mouseDownEvent.locationInWindow

        btnFocus.highlight(true)

        // Track events until the mouse is up (in which we interpret as a click), or a drag starts (in which we pass off to the Window Server to perform the drag)
        var shouldCallSuper = false

        // trackEvents won't return until after the tracking all ends
        window.trackEvents(matching: [.leftMouseDragged, .leftMouseUp], timeout: NSEvent.foreverDuration, mode: .default) { event, stop in
            guard let event = event else { return }
            switch event.type {
            case .leftMouseUp:
                // Stop on a mouse up; post it back into the queue and call super so it can handle it
                shouldCallSuper = true
                NSApp.postEvent(event, atStart: false)
                stop.pointee = true

            case .leftMouseDragged:
                // track mouse drags, and if more than a few points are moved we start a drag
                let currentPoint = event.locationInWindow
                if abs(currentPoint.x - startingPoint.x) >= 5 || fabs(currentPoint.y - startingPoint.y) >= 5 {
                    btnFocus.highlight(false)
                    stop.pointee = true
                    window.performDrag(with: event)
                }

            default:
                break
            }
        }

        if shouldCallSuper {
            super.mouseDown(with: mouseDownEvent)
        }
    }
}
