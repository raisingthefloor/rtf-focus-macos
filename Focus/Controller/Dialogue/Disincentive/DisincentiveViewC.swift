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

class DisincentiveViewC: NSViewController {
    @IBOutlet var lblDesc: NSTextField!
    @IBOutlet var lblSubDesc: NSTextField!
    @IBOutlet var lblCharacter: NSTextField!
    @IBOutlet var txtCharacter: NSTextField!
    @IBOutlet var btnNever: CustomButton!
    @IBOutlet var btnDone: CustomButton!

    var dialogueType: FocusDialogue = .disincentive_xx_character_alert

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
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
    }

    func setUpViews() {
        lblCharacter.isHidden = (dialogueType == .disincentive_signout_signin_alert)
        txtCharacter.isHidden = (dialogueType == .disincentive_signout_signin_alert)
        themeSetUp()
    }

    func themeSetUp() {
        btnNever.buttonColor = dialogueType.green
        btnNever.activeButtonColor = dialogueType.green
        btnNever.textColor = .white

        btnDone.buttonColor = dialogueType.mixedColor
        btnDone.activeButtonColor = dialogueType.mixedColor
        btnDone.textColor = .white
    }

    func bindData() {
        btnDone.target = self
        btnDone.action = #selector(doneClick(_:))
        btnNever.target = self
        btnNever.action = #selector(neverClick(_:))
    }
}

extension DisincentiveViewC {
    @objc func doneClick(_ sender: NSButton) {
        if dialogueType == .disincentive_signout_signin_alert {
        } else {
            // Match the random value and complete the session
            if lblCharacter.stringValue == txtCharacter.stringValue {
                // complete the session
            } else {
            }
        }
    }

    @objc func neverClick(_ sender: NSButton) {
        // Take back to previous window from where it opens
    }
}
