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

import Carbon.HIToolbox
import Cocoa

class DisincentiveViewC: NSViewController {
    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var lblDesc: NSTextField!
    @IBOutlet var lblSubDesc: NSTextField!
    @IBOutlet var lblCharacter: NSTextField!
    @IBOutlet var randomSV: NSStackView!
    @IBOutlet var lblError: NSTextField!
    @IBOutlet var txtCharacter: NSTextField!

    @IBOutlet var btnNever: CustomButton!
    @IBOutlet var btnDone: CustomButton!

    @IBOutlet var lblBlock: NSTextField!

    var dialogueType: FocusDialogue = .disincentive_xx_character_alert
    var updateFocusStop: ((ButtonAction) -> Void)?
    var objBl: Block_List?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
        setupRandomCharacter()
    }
}

extension DisincentiveViewC: BasicSetupType {
    func setUpText() {
        lblDesc.stringValue = dialogueType.description
        lblSubDesc.stringValue = dialogueType.sub_description
        lblCharacter.stringValue = String.randomString(length: 30)

        let buttonsV = dialogueType.option_buttons
        btnDone.title = buttonsV.last ?? ""
        btnNever.title = buttonsV.first ?? ""
        lblError.stringValue = NSLocalizedString("Error.random_character_invalid", comment: "Character mismatched.Try Again.")
        lblError.textColor = Color.red_color
        let subTitle = NSLocalizedString("Alert.disincentive.show_blocklist", comment: "Show me the blocklist that requires this ...")
        let attributedText = NSMutableAttributedString.getAttributedString(fromString: subTitle)
        attributedText.underLine(subString: subTitle)
        lblBlock.attributedStringValue = attributedText
    }

    func setUpViews() {
        NSApp.windows.forEach({ $0.center() })
        lblCharacter.isHidden = (dialogueType == .disincentive_signout_signin_alert)
        randomSV.isHidden = (dialogueType == .disincentive_signout_signin_alert)
        lblSubDesc.font = dialogueType.subdesc_font
        txtCharacter.delegate = self
        themeSetUp()
    }

    func themeSetUp() {
        lblTitle.font = NSFont.systemFont(ofSize: 18, weight: .bold)
        lblDesc.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        lblCharacter.font = NSFont.systemFont(ofSize: 12, weight: .bold)

        let bg_color = dialogueType.option_buttons_theme.bg_color
        let b_color = dialogueType.option_buttons_theme.border_color
        let bwidth = dialogueType.option_buttons_theme.border_width
        let font_color = dialogueType.option_buttons_theme.font_color

        btnNever.buttonColor = bg_color.first ?? Color.green_color
        btnNever.activeButtonColor = bg_color.first ?? Color.green_color
        btnNever.textColor = font_color.first ?? .white
        btnNever.borderColor = b_color.first ?? Color.green_color
        btnNever.borderWidth = bwidth
        btnNever.font = NSFont.systemFont(ofSize: 13, weight: .bold)

        btnDone.buttonColor = bg_color.last ?? Color.light_green_color
        btnDone.activeButtonColor = bg_color.last ?? Color.light_green_color
        btnDone.textColor = font_color.last ?? .white
        btnDone.borderColor = b_color.last ?? Color.green_color
        btnDone.borderWidth = bwidth
        btnDone.font = NSFont.systemFont(ofSize: 13, weight: .bold)

        lblSubDesc.textColor = (dialogueType == .disincentive_xx_character_alert) ? .black : Color.blue_color
        lblBlock.textColor = Color.blue_color

        view.border_color = Color.green_color
        view.border_width = 1
        view.background_color = Color.dialogue_bg_color
        view.corner_radius = 10
        btnDone.isEnabled = (dialogueType == .disincentive_xx_character_alert) ? false : true
    }

    func bindData() {
        btnDone.target = self
        btnDone.action = #selector(doneClick(_:))

        btnNever.target = self
        btnNever.action = #selector(neverClick(_:))

        let g = NSClickGestureRecognizer(target: self, action: #selector(openBlockList))
        g.numberOfClicksRequired = 1
        lblBlock.addGestureRecognizer(g)
    }

    func setupRandomCharacter() {
        if let objB = objBl {
            let randomVal = objB.character_val
            lblCharacter.stringValue = String.randomString(length: randomVal)
        }
    }
}

extension DisincentiveViewC: NSTextFieldDelegate {
    func controlTextDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextField else { return }
        btnDone.isEnabled = !textView.stringValue.isEmpty
    }

    @objc func openBlockList() {
        if let vc = WindowsManager.getVC(withIdentifier: "sidCustomSetting", ofType: CustomSettingController.self, storyboard: "CustomSetting") {
            vc.selectOption = SettingOptions.block_setting
            presentAsModalWindow(vc)
        }
    }

    @objc func doneClick(_ sender: NSButton) {
        if dialogueType == .disincentive_signout_signin_alert {
            AppManager.shared.stopScriptObserver()
            WindowsManager.openSystemLogoutDialog()
//            updateFocusStop?(.stop_session)
//            dismiss(nil)
        } else {
            // Match the random value and complete the session
            if lblCharacter.stringValue == txtCharacter.stringValue {
                lblError.isHidden = true
                updateFocusStop?(.stop_session)
                dismiss(nil)
            } else {
                lblError.isHidden = false
            }
        }
    }

    @objc func neverClick(_ sender: NSButton) {
        // Take back to previous window from where it opens
        if dialogueType == .disincentive_signout_signin_alert {
            if !(AppManager.shared.browserBridge?.isFocusing ?? false) {
                startBlockingAppsWeb()
            }
        }
        updateFocusStop?(.normal_ok)
        dismiss(nil)
    }

    func startBlockingAppsWeb() {
        guard let obj = DBManager.shared.getCurrentSession() else { return }

        if obj.is_block_programe_select {
            AppManager.shared.addObserverToCheckAppLaunch()
            WindowsManager.blockWebSite()
        }

        if obj.is_dnd_mode {
            WindowsManager.runDndCommand(cmd: "on")
        }
    }
}
