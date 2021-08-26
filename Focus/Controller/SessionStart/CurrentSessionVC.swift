//
//  CurrentSessionVC.swift
//  Focus
//
//  Created by Bhavi on 25/08/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
    }
}

extension CurrentSessionVC: BasicSetupType {
    func setUpText() {
        title = NSLocalizedString("Session.title", comment: "Currently Running Focus Session(s)")
        lblTitle.stringValue = NSLocalizedString("Session.title", comment: "Currently Running Focus Session(s)")

        let subTitle = NSLocalizedString("Session.ur_next_break", comment: "Your next break is in ") + "12 minutes"
        let attributedText = NSMutableAttributedString.getAttributedString(fromString: subTitle)
        attributedText.apply(color: Color.blue_color, subString: "12 minutes")
        attributedText.apply(color: Color.blue_color, subString: subTitle)
        attributedText.apply(font: NSFont.systemFont(ofSize: 13, weight: .regular), subString: subTitle)
        attributedText.apply(font: NSFont.systemFont(ofSize: 13, weight: .bold), subString: "12 minutes")
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
    }

    @objc func openCustomSetting() {
        if let vc = WindowsManager.getVC(withIdentifier: "sidCustomSetting", ofType: CustomSettingController.self, storyboard: "CustomSetting") {
            presentAsSheet(vc)
        }
    }

    @objc func startSession(_ sender: NSButton) {
        // Action perform for starting the session
    }

    @objc func okAction(_ sender: NSButton) {
        // Action perform for OK
    }

    func setFocusSessionView() {
        // Perform the task dynamically
        let sessionV = SessionInfoView()
        sessionStack.addArrangedSubview(sessionV)
//        let sessionV1 = SessionInfoView()
//        sessionStack.addArrangedSubview(sessionV1)
    }
}
