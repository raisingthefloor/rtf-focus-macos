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

class CurrentSessionVC: BaseViewController {
    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var lblSubTitle: NSTextField!

    @IBOutlet var bottomView: NSView!
    @IBOutlet var lblSetting: NSTextField!

    @IBOutlet var sessionStack: NSStackView!

    @IBOutlet var btnOk: CustomButton!
    @IBOutlet var btnStart: CustomButton!
    @IBOutlet var lblWhy: NSTextField!

    var timer: Timer?
    var viewModel: MenuViewModelType?
    var updateView: ((Bool, ButtonAction) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        bindData()
        startTimer()
    }

    func startTimer() {
        if timer == nil {
            DispatchQueue.global(qos: .background).async(execute: { () -> Void in
                self.timer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateInformation), userInfo: nil, repeats: true)
                RunLoop.current.add(self.timer!, forMode: .default)
                RunLoop.current.run()
            })
        }
    }

    @objc func updateInformation() {
        DispatchQueue.main.async {
            self.setUpText()
            self.sessionStack.subviews.forEach({ ($0 as? SessionInfoView)?.setupSessionData(obj: ($0 as? SessionInfoView)?.objFL) })
        }
    }

    func stopTimer() {
        DispatchQueue.global(qos: .background).async(execute: { () -> Void in
            self.timer?.invalidate()
            self.timer = nil
        })
    }
}

extension CurrentSessionVC: BasicSetupType {
    func setUpText() {
        let objFocus = viewModel?.input.focusObj

        lblTitle.stringValue = NSLocalizedString("Session.title", comment: "Currently Running Focus Session(s)")

        var remaing_break_time = Int(objFocus?.combine_stop_focus_after_time ?? 100)
        print("**** CURRENT Focus Length For BREAK APPEAR **** : \(remaing_break_time)")
        print("**** CURRENT DECREASE BREAK TIME : decrease_break_time Time **** : \(Int(objFocus?.decrease_break_time ?? 0))")

        remaing_break_time = (objFocus?.is_break_time ?? false) ? Int(objFocus?.remaining_break_time ?? 100) : (remaing_break_time - Int(objFocus?.decrease_break_time ?? 0))

        print("**** CURRENT Focus Length For BREAK TIME REMAINING **** : \(remaing_break_time)")

        let break_time = (objFocus?.is_break_time ?? false) ? remaing_break_time.secondsToTime() : remaing_break_time.secondsToTime()
        print("**** CURRENT BREAK TIME Time **** : \(break_time)")

        var time = ""
        if break_time.timeInHours != 0 {
            time = "\(break_time.timeInHours) hrs \(break_time.timeInMinutes) minutes"
        } else {
            time = "\(break_time.timeInMinutes) minutes \(break_time.timeInSeconds) sec"
        }

        let subTitle_0 = (objFocus?.is_break_time ?? false) ? NSLocalizedString("Session.ur_break_end", comment: "Your break ends ") : NSLocalizedString("Session.ur_next_break", comment: "Your next break is in ")

        let subTitle = subTitle_0 + time
        let attributedText = NSMutableAttributedString.getAttributedString(fromString: subTitle)
        attributedText.apply(color: Color.blue_color, subString: time)
        attributedText.apply(color: Color.blue_color, subString: subTitle)
        attributedText.apply(font: NSFont.systemFont(ofSize: 13, weight: .regular), subString: subTitle)
        attributedText.apply(font: NSFont.systemFont(ofSize: 13, weight: .bold), subString: time)
        lblSubTitle.attributedStringValue = attributedText

        let customize_setting = NSLocalizedString("Home.customize_setting", comment: "Customize Focus")
        let customize_setting_str = NSMutableAttributedString.getAttributedString(fromString: customize_setting)
        customize_setting_str.underLine(subString: customize_setting, lineColor: .white)
        customize_setting_str.apply(color: .white, subString: customize_setting)
        lblSetting.attributedStringValue = customize_setting_str

        lblWhy.stringValue = NSLocalizedString("Session.why_do_this", comment: "Why do this?")
        lblWhy.addUnderline()
        btnStart.title = NSLocalizedString("Session.start_focus_session", comment: "Start a 2nd focus session")
        btnOk.title = NSLocalizedString("Button.ok", comment: "OK").uppercased()
    }

    func setUpViews() {
        title = "" // NSLocalizedString("Session.title", comment: "Currently Running Focus Session(s)")

        NotificationCenter.default.addObserver(self, selector: #selector(setFocusSessionView), name: NSNotification.Name(ObserverName.update_current_session_ui.rawValue), object: nil)

        setFocusSessionView()
        themeSetUp()
    }

    func themeSetUp() {
        bottomView.bgColor = Color.navy_blue_color
        lblSetting.textColor = .white
        lblSubTitle.textColor = Color.blue_color
        lblWhy.textColor = Color.blue_color

        btnStart.buttonColor = Color.light_green_color
        btnStart.activeButtonColor = Color.light_green_color
        btnStart.textColor = Color.green_color
        btnStart.borderColor = Color.green_color
        btnStart.borderWidth = 0.6

        btnOk.buttonColor = Color.green_color
        btnOk.activeButtonColor = Color.green_color
        btnOk.textColor = .white
    }

    func bindData() {
        let g = NSClickGestureRecognizer(target: self, action: #selector(openCustomSetting))
        g.numberOfClicksRequired = 1
        bottomView.addGestureRecognizer(g)

        btnStart.target = self
        btnStart.action = #selector(startSession(_:))

        btnOk.target = self
        btnOk.action = #selector(okAction(_:))

        urllink = Config.why_do_this_link
        let gesture = NSClickGestureRecognizer(target: self, action: #selector(openBrowser))
        gesture.numberOfClicksRequired = 1
        lblWhy.addGestureRecognizer(gesture) // Need to set range click
    }

    @objc func setFocusSessionView() {
        guard let objFocus = viewModel?.input.focusObj, let arrSession = objFocus.focuses?.allObjects as? [Focus_List] else { return }
        DispatchQueue.main.async {
            self.lblSubTitle.isHidden = objFocus.focus_untill_stop ? true : false
            self.lblSubTitle.isHidden = objFocus.is_provided_short_break ? false : true
            self.btnStart.isHidden = arrSession.count > 1
            self.lblWhy.isHidden = arrSession.count > 1

            self.sessionStack.removeSubviews()

            var i = 0
            for session in arrSession.sorted(by: { $0.created_date ?? Date() < $1.created_date ?? Date() }) {
                let sessionView = SessionInfoView()
                sessionView.setupSessionData(obj: session)
                sessionView.btnStop.target = self
                sessionView.btnStop.action = #selector(self.stopAction(_:))
                sessionView.btnStop.tag = i
                sessionView.titleV?.isHidden = (arrSession.count == 1)
                sessionView.lblTitle.stringValue = NSLocalizedString("Session.focus_session", comment: "Focus Session") + " " + String(i + 1)
                self.sessionStack.addArrangedSubview(sessionView)
                i = i + 1
            }
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        stopTimer()
    }
}

extension CurrentSessionVC {
    @objc func openCustomSetting() {
        stopTimer()
        if let controller = WindowsManager.getVC(withIdentifier: "sidCustomSetting", ofType: CustomSettingController.self, storyboard: "CustomSetting") {
            controller.selectOption = SettingOptions.general_setting
            controller.updateView = { [weak self] _ in
                self?.startTimer()
            }
            presentAsModalWindow(controller)
        }
    }

    @objc func startSession(_ sender: NSButton) {
        // Action perform for starting the session
        stopTimer()

        if let controller = WindowsManager.getVC(withIdentifier: "sidMenuController", ofType: MenuController.self) {
            updateView?(true, .initiate_new_session)
            controller.viewModel.viewCntrl = .current_session
            controller.focusStart = { [weak self] isStarted in
                self?.startTimer()
                if isStarted {
                    self?.updateView?(false, .started_new_session)
                    self?.setFocusSessionView()
                } else {
                    self?.updateView?(false, .cancel_new_session)
                }
            }
            presentAsModalWindow(controller)
        }
    }

    @objc func okAction(_ sender: NSButton) {
        // Action perform for OK
        stopTimer()
        dismiss(nil)
    }

    @objc func stopAction(_ sender: NSButton) {
        stopTimer()
        guard let objFocus = viewModel?.input.focusObj, var arrSession = objFocus.focuses?.allObjects as? [Focus_List], !arrSession.isEmpty else {
            updateView?(true, .stop_session)
            dismiss(nil)
            return
        }
        arrSession = arrSession.sorted(by: { $0.created_date ?? Date() < $1.created_date ?? Date() })
        let objSession = arrSession[sender.tag]

        guard let bl_id = objSession.block_list_id else {
            if arrSession.count > 1 {
                updateSesionAfterStop(focus: objSession)
            } else {
                updateView?(true, .stop_session)
                dismiss(nil)
            }
            return
        }

        let objBl = DBManager.shared.getBlockListBy(id: bl_id)

        if objBl?.stop_focus_session_anytime ?? false {
            if arrSession.count > 1 {
                updateSesionAfterStop(focus: objSession)
            } else {
                updateView?(true, .stop_session)
                dismiss(nil)
            }
            return
        }
        Config.start_date_time = Date()
        let controller = DisincentiveViewC(nibName: "DisincentiveViewC", bundle: nil)
        controller.objBl = objBl
        controller.dialogueType = (objBl?.random_character ?? false) ? .disincentive_xx_character_alert : .disincentive_signout_signin_alert
        controller.updateFocusStop = { focusStop in
            if arrSession.count > 1 && focusStop == .stop_session {
                self.updateSesionAfterStop(focus: objSession)
            } else {
                self.updateView?(focusStop == .stop_session, focusStop)
                self.dismiss(nil)
            }
        }
        presentAsSheet(controller)
    }

    func updateSesionAfterStop(focus: Focus_List) {
        updateView?(true, .initiate_new_session)
        DBManager.shared.updateRunningSession(focus: focus)
        updateView?(false, .cancel_new_session)
        setFocusSessionView()
        startTimer()
    }
}
