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

    var viewModel: MenuViewModelType?
    var updateView: ((Bool, ButtonAction) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
    }
}

extension CurrentSessionVC: BasicSetupType {
    func setUpText() {
        let objFocus = viewModel?.input.focusObj
        let break_time = (objFocus?.is_break_time ?? false) ? Int(objFocus?.remaining_break_time ?? 100).secondsToTime() : Int(objFocus?.stop_focus_after_time ?? 100).secondsToTime()

        var time = ""
        if break_time.timeInHours != 0 {
            time = "\(break_time.timeInHours) hrs \(break_time.timeInMinutes) minutes"
        } else {
            time = "\(break_time.timeInMinutes) minutes"
        }

        title = NSLocalizedString("Session.title", comment: "Currently Running Focus Session(s)")
        lblTitle.stringValue = NSLocalizedString("Session.title", comment: "Currently Running Focus Session(s)")

        let subTitle_0 = (objFocus?.is_break_time ?? false) ? NSLocalizedString("Session.ur_break_end", comment: "Your break ends ") : NSLocalizedString("Session.ur_next_break", comment: "Your next break is in ")

        let subTitle = subTitle_0 + time
        let attributedText = NSMutableAttributedString.getAttributedString(fromString: subTitle)
        attributedText.apply(color: Color.blue_color, subString: time)
        attributedText.apply(color: Color.blue_color, subString: subTitle)
        attributedText.apply(font: NSFont.systemFont(ofSize: 13, weight: .regular), subString: subTitle)
        attributedText.apply(font: NSFont.systemFont(ofSize: 13, weight: .bold), subString: time)
        lblSubTitle.attributedStringValue = attributedText

        lblSetting.stringValue = NSLocalizedString("Home.customize_setting", comment: "Customize Setting")
        lblWhy.stringValue = NSLocalizedString("Session.why_do_this", comment: "Why do this?")
        lblWhy.addUnderline()
        btnStart.title = NSLocalizedString("Session.start_focus_session", comment: "Start a 2nd focus session")
        btnOk.title = NSLocalizedString("Button.ok", comment: "OK").uppercased()
    }

    func setUpViews() {
        if let window: NSWindow = view.window {
            window.styleMask.remove(.fullScreen)
            window.styleMask.remove(.resizable)
            window.styleMask.remove(.miniaturizable)
            window.styleMask.remove(.fullSizeContentView)
        }
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

    func setFocusSessionView() {
        // TODO: With Two Sesison Data setup Dynamically pending
        let objFocus = viewModel?.input.focusObj
        lblSubTitle.isHidden = (objFocus?.focus_untill_stop ?? false) ? true : false

        let sessionV = SessionInfoView()
        sessionV.setupSingleData()
        sessionV.btnStop.target = self
        sessionV.btnStop.action = #selector(stopAction(_:))
        sessionStack.addArrangedSubview(sessionV)
//        let sessionV1 = SessionInfoView()
//        sessionStack.addArrangedSubview(sessionV1)
    }
}

extension CurrentSessionVC {
    @objc func openCustomSetting() {
        if let vc = WindowsManager.getVC(withIdentifier: "sidCustomSetting", ofType: CustomSettingController.self, storyboard: "CustomSetting") {
            vc.selectOption = SettingOptions.general_setting
            presentAsModalWindow(vc)
        }
    }

    @objc func startSession(_ sender: NSButton) {
        // Action perform for starting the session
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = "Underconstruction!!!"
        alert.runModal()
    }

    @objc func okAction(_ sender: NSButton) {
        // Action perform for OK
        dismiss(nil)
    }

    @objc func stopAction(_ sender: NSButton) {
        guard let objBl = DBManager.shared.getCurrentBlockList().objBl else {
            updateView?(true, .stop_session)
            dismiss(nil)
            return
        }

        if objBl.stop_focus_session_anytime {
            updateView?(true, .stop_session)
            dismiss(nil)
            return
        }

//        let presentingCtrl = WindowsManager.getPresentingController()
        // Need to check the Condition as if all false but that never happedn
        let controller = DisincentiveViewC(nibName: "DisincentiveViewC", bundle: nil)
        controller.dialogueType = (objBl.random_character) ? .disincentive_xx_character_alert : .disincentive_signout_signin_alert
        controller.updateFocusStop = { focusStop in
            self.updateView?(focusStop == .stop_session, focusStop)
            self.dismiss(nil)
        }
        presentAsSheet(controller)
    }
}
