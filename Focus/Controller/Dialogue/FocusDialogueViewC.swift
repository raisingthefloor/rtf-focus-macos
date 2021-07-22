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
    }
}

extension FocusDialogueViewC: BasicSetupType {
    func setUpText() {
        lblTitle.stringValue = dialogueType.title
        lblDesc.stringValue = dialogueType.description
        lblSubDesc.stringValue = dialogueType.sub_description
        lblSubTitle.stringValue = dialogueType.extented_title
        let buttonsValue = dialogueType.option_buttons.titles
        let position = dialogueType.option_buttons.position

        if buttonsValue.count > 0 {
            btnGreen.title = buttonsValue.first ?? "-"
            btnRed.title = buttonsValue.last ?? "-"
            btnTop.title = buttonsValue.first ?? ""
            btnTop.isHidden = (position == .bottom) == true
            btnGreen.isHidden = (position == .up_down) == true
        } else {
            btnGreen.isHidden = true
            btnRed.title = dialogueType.extented_buttons.first ?? "-"
        }
    }

    func setUpViews() {
        lblTitle.isHidden = dialogueType.title.isEmpty
        lblDesc.isHidden = dialogueType.description.isEmpty
        lblSubDesc.isHidden = dialogueType.sub_description.isEmpty
        lblSubTitle.isHidden = dialogueType.extented_title.isEmpty

        for value in dialogueType.extented_buttons {
            let btn = NSButton(title: value, target: self, action: #selector(extendTimeAction(_:)))
            btnStackV.addArrangedSubview(btn)
        }
    }

    func bindData() {
    }

    @objc func extendTimeAction(_ sender: NSButton) {
    }
}
