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
    var sessionDone: ((ButtonAction, Int, ButtonValueType) -> Void)?

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
        guard let objFocus = DBManager.shared.getCurrentSession(), var focuslist = objFocus.focuses?.allObjects as? [Focus_List] else { return }
        focuslist = focuslist.sorted(by: { $0.created_date ?? Date() < $1.created_date ?? Date() })

        let objSession = focuslist.last
        title = dialogueType.title
        lblTitle.stringValue = dialogueType.title

        var time = ""
        let comp = Int(objSession?.used_time ?? 100).secondsToFullTime()
        if comp.timeInHours != 0 {
            time = "\(comp.timeInHours) hrs \(comp.timeInMinutes) min \(comp.timeInSeconds) sec"
        } else {
            time = "\(comp.timeInMinutes) minutes"
        }

        let focusInfo = dialogueType.description + time

        let attributedText = NSMutableAttributedString.getAttributedString(fromString: focusInfo)
        attributedText.apply(color: Color.black_color, subString: focusInfo)
        attributedText.apply(font: NSFont.systemFont(ofSize: 12, weight: .regular), subString: focusInfo)
        attributedText.apply(font: NSFont.systemFont(ofSize: 12, weight: .bold), subString: time)
        attributedText.alignment(alignment: .center, subString: focusInfo)
        lblDesc.attributedStringValue = attributedText
        lblDesc.alignment = .center

        lblSubDesc.stringValue = dialogueType.sub_description
    }

    func setUpViews() {
        WindowsManager.setDialogueInCenter()

        var i = 0 // for test
        for value in dialogueType.extented_buttons {
            let btn = CustomButton(title: value, target: self, action: #selector(extendTimeAction(_:)))
            btn.tag = i
            btn.buttonColor = dialogueType.light_green
            btn.activeButtonColor = dialogueType.light_green
            btn.textColor = dialogueType.green
            btn.borderColor = dialogueType.green
            btn.font = NSFont.systemFont(ofSize: 13, weight: .bold)
            btn.borderWidth = 0.5
            enableDisable(btn: btn)
            i = i + 1
            btnStackV.addArrangedSubview(btn)
        }
    }

    func themeSetUp() {
        lblTitle.font = NSFont.systemFont(ofSize: 18, weight: .bold)
        lblSubDesc.font = NSFont.systemFont(ofSize: 12, weight: .regular)

        btnOk.buttonColor = dialogueType.green
        btnOk.activeButtonColor = dialogueType.green
        btnOk.textColor = .white
        btnOk.font = NSFont.systemFont(ofSize: 13, weight: .bold)

        view.border_color = Color.green_color
        view.border_width = 1
        view.background_color = Color.dialogue_bg_color
        view.corner_radius = 10
    }

    func bindData() {
        btnOk.target = self
        btnOk.action = #selector(okAction(_:))
    }

    func enableDisable(btn: CustomButton) {
        if !dialogueType.is_extented_buttons.isEmpty {
            btn.isEnabled = !dialogueType.is_extented_buttons[btn.tag]
        }
    }

    @objc func extendTimeAction(_ sender: NSButton) {
        let extendVal = dialogueType.value[sender.tag]
        sessionDone?(dialogueType.action, extendVal, ButtonValueType(rawValue: sender.tag)!)
        dismiss(nil)
    }

    @objc func okAction(_ sender: NSButton) {
        sessionDone?(.normal_ok, 0, .none)
        dismiss(nil)
    }
}
