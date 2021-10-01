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
    @IBOutlet var lblDesc: NSTextField!
    @IBOutlet var lblSubDesc: NSTextField!
    @IBOutlet var lblCharacter: NSTextField!
    @IBOutlet var txtCharacter: NSTextField!
    @IBOutlet var btnNever: CustomButton!
    @IBOutlet var btnDone: CustomButton!

    @IBOutlet var lblBlock: NSTextField!

    var dialogueType: FocusDialogue = .disincentive_xx_character_alert

    var updateFocusStop: ((ButtonAction) -> Void)?

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
        let buttonsV = dialogueType.option_buttons.titles
        btnDone.title = buttonsV.last ?? ""
        btnNever.title = buttonsV.first ?? ""

        let subTitle = NSLocalizedString("Alert.disincentive.show_blocklist", comment: "Show me the blocklist that requires this ...")
        let attributedText = NSMutableAttributedString.getAttributedString(fromString: subTitle)
        attributedText.underLine(subString: subTitle)
        lblBlock.attributedStringValue = attributedText
    }

    func setUpViews() {
        lblCharacter.isHidden = (dialogueType == .disincentive_signout_signin_alert)
        txtCharacter.isHidden = (dialogueType == .disincentive_signout_signin_alert)
        themeSetUp()
    }

    func themeSetUp() {
        let bg_color = dialogueType.option_buttons_theme.bg_color
        let b_color = dialogueType.option_buttons_theme.border_color
        let bwidth = dialogueType.option_buttons_theme.border_width
        let font_color = dialogueType.option_buttons_theme.font_color

        btnNever.buttonColor = bg_color.first ?? Color.green_color
        btnNever.activeButtonColor = bg_color.first ?? Color.green_color
        btnNever.textColor = font_color.first ?? .white
        btnNever.borderColor = b_color.first ?? Color.green_color
        btnNever.borderWidth = bwidth

        btnDone.buttonColor = bg_color.last ?? Color.light_green_color
        btnDone.activeButtonColor = bg_color.last ?? Color.light_green_color
        btnDone.textColor = font_color.last ?? .white
        btnDone.borderColor = b_color.last ?? Color.green_color
        btnDone.borderWidth = bwidth

        lblSubDesc.textColor = (dialogueType == .disincentive_xx_character_alert) ? .black : Color.blue_color
        lblBlock.textColor = Color.blue_color
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
        if let objB = DBManager.shared.getCurrentBlockList().objBl {
            let randomVal = objB.character_val
            lblCharacter.stringValue = String.randomString(length: randomVal)
//            txtCharacter.stringValue = lblCharacter.stringValue
        }
    }
}

extension DisincentiveViewC {
    @objc func openBlockList() {
        // TODO: Open Block list View

        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = "In Progress, Which Screen we have to open?"
        alert.runModal()
    }

    @objc func doneClick(_ sender: NSButton) {
        if dialogueType == .disincentive_signout_signin_alert {
            updateFocusStop?(.stop_session)
            WindowsManager.openSystemLogoutDialog()
            dismiss(nil)
        } else {
            // Match the random value and complete the session
            if lblCharacter.stringValue == txtCharacter.stringValue {
                updateFocusStop?(.stop_session)
                dismiss(nil)
            } else {
            }
        }
    }

//    GwEUf45HBLDKSG56BNBFdbNBIV110nWI
    @objc func neverClick(_ sender: NSButton) {
        // Take back to previous window from where it opens
        updateFocusStop?(.normal_ok)
        dismiss(nil)
    }
}
