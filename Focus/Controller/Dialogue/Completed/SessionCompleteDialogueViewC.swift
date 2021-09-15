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

class SessionCompleteDialogueViewC: NSViewController {
    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var lblDesc: NSTextField!
    @IBOutlet var lblSubDesc: NSTextField!
    @IBOutlet var btnOk: CustomButton!
    @IBOutlet var seperateV: NSBox!
    @IBOutlet var btnStackV: NSStackView!

    var dialogueType: FocusDialogue = .seession_completed_alert

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        themeSetUp()
        bindData()
    }
}

extension SessionCompleteDialogueViewC: BasicSetupType {
    func setUpText() {
        title = dialogueType.title
        lblTitle.stringValue = dialogueType.title
        lblDesc.stringValue = dialogueType.description
        lblSubDesc.stringValue = dialogueType.sub_description
    }

    func setUpViews() {
        view.window?.level = .floating

        var i = 0 // for test
        for value in dialogueType.extented_buttons {
            let btn = CustomButton(title: value, target: self, action: #selector(extendTimeAction(_:)))
            btn.tag = i
            btn.buttonColor = dialogueType.light_green
            btn.activeButtonColor = dialogueType.light_green
            btn.textColor = dialogueType.green
            btn.borderColor = dialogueType.green
            btn.borderWidth = 0.5
            i = i + 1
            btnStackV.addArrangedSubview(btn)
        }
    }

    func themeSetUp() {
        lblTitle.font = NSFont.systemFont(ofSize: 20, weight: .medium)

        btnOk.buttonColor = dialogueType.green
        btnOk.activeButtonColor = dialogueType.green
        btnOk.textColor = .white
    }

    func bindData() {
        btnOk.target = self
        btnOk.action = #selector(okAction(_:))
    }

    @objc func extendTimeAction(_ sender: NSButton) {
        if sender.tag == 0 {
            blockAppDialogue()
        } else if sender.tag == 1 {
            let controller = FocusDialogueViewC(nibName: "FocusDialogueViewC", bundle: nil)
            controller.dialogueType = .long_break_alert
            presentAsSheet(controller)
        } else if sender.tag == 2 {
            completeSession()
        }
    }

    @objc func okAction(_ sender: NSButton) {
        dismiss(nil)
    }

    func blockAppDialogue() {
        let controller = BlockAppDialogueViewC(nibName: "BlockAppDialogueViewC", bundle: nil)
        controller.dialogueType = .launch_block_app_alert
        presentAsSheet(controller)
    }

    func completeSession() {
        let controller = SessionCompleteDialogueViewC(nibName: "SessionCompleteDialogueViewC", bundle: nil)
        controller.dialogueType = .seession_completed_alert
        presentAsSheet(controller)
    }
}
