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

class FocusDialogueViewC: NSViewController {
    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var lblDesc: NSTextField!
    @IBOutlet var lblSubDesc: NSTextField!
    @IBOutlet var btnTop: NSButton!
    @IBOutlet var containerView: NSView!
    @IBOutlet var lblSubTitle: NSTextField!
    @IBOutlet var btnStackV: NSStackView!
    @IBOutlet var btnGreen: NSButton!
    @IBOutlet var btnRed: NSButton!

    var dialogueType: FocusDialogue = .break_sequence_alert

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        themeSetUp()
    }
}

extension FocusDialogueViewC: BasicSetupType {
    func setUpText() {
        title = NSLocalizedString("APP.Name", comment: "Focus")
        lblTitle.stringValue = dialogueType.title
        lblDesc.stringValue = dialogueType.description
        lblSubDesc.stringValue = dialogueType.sub_description

        lblSubTitle.stringValue = dialogueType.extented_title
        let buttonsValue = dialogueType.option_buttons.titles
        let position = dialogueType.option_buttons.position

        if buttonsValue.count > 1 {
            btnGreen.title = buttonsValue.first ?? "-"
            btnRed.title = buttonsValue.last ?? "-"
            btnTop.title = buttonsValue.first ?? ""
            btnTop.isHidden = (position == .bottom) == true
            btnGreen.isHidden = (position == .up_down) == true
        } else {
            btnGreen.isHidden = true
            btnTop.isHidden = true
            btnRed.title = buttonsValue.first ?? "-"
        }
    }

    func setUpViews() {
        lblTitle.isHidden = dialogueType.title.isEmpty
        lblDesc.isHidden = dialogueType.description.isEmpty
        lblSubDesc.isHidden = dialogueType.sub_description.isEmpty
        lblSubTitle.isHidden = dialogueType.extented_title.isEmpty
        containerView.isHidden = dialogueType.extented_buttons.isEmpty

        var i = 0 // for test
        for value in dialogueType.extented_buttons {
            let btn = NSButton(title: value, target: self, action: #selector(extendTimeAction(_:)))
            btn.tag = i
            btn.bezelStyle = .texturedRounded
            btn.isBordered = false // Important
            btn.wantsLayer = true
            btn.layer?.backgroundColor = .black
            btn.layer?.cornerRadius = 6
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.heightAnchor.constraint(equalToConstant: 35).isActive = true
            btn.widthAnchor.constraint(equalToConstant: 70).isActive = true

            i = i + 1
            btnStackV.addArrangedSubview(btn)
        }
    }

    func themeSetUp() {
        lblSubTitle.textColor = .black
        // containerView.bgColor = Color.light_blue_color
    }

    func bindData() {
        btnGreen.target = self
        btnGreen.action = #selector(greenAction(_:))

        btnRed.target = self
        btnRed.action = #selector(redAction(_:))

        btnTop.target = self
        btnTop.action = #selector(topAction(_:))
    }

    @objc func extendTimeAction(_ sender: NSButton) {
        let controller = FocusDialogueViewC(nibName: "FocusDialogueViewC", bundle: nil)
        if sender.tag == 0 {
            controller.dialogueType = .launch_app_alert
            presentAsModalWindow(controller)
        } else if sender.tag == 1 {
            controller.dialogueType = .warning_forced_pause_alert
            presentAsModalWindow(controller)

        } else if sender.tag == 2 {
            controller.dialogueType = .seession_completed_alert
            presentAsModalWindow(controller)

        } else {
            
        }
    }

    @objc func greenAction(_ sender: NSButton) {
        
    }

    @objc func redAction(_ sender: NSButton) {
    }

    @objc func topAction(_ sender: NSButton) {
    }
}
