//
//  SessionCompleteDialogueViewC.swift
//  Focus
//
//  Created by Bhavi on 06/09/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Cocoa

class SessionCompleteDialogueViewC: NSViewController {
    
    
    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var lblDesc: NSTextField!
    @IBOutlet var lblSubDesc: NSTextField!
    @IBOutlet var btnOk: CustomButton!
    @IBOutlet weak var seperateV: NSBox!
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
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.heightAnchor.constraint(equalToConstant: 35).isActive = true
            btn.widthAnchor.constraint(equalToConstant: 70).isActive = true

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
        let controller = FocusDialogueViewC(nibName: "FocusDialogueViewC", bundle: nil)
        if sender.tag == 0 {
            controller.dialogueType = .launch_app_alert
        } else if sender.tag == 1 {
            controller.dialogueType = .warning_forced_pause_alert
        } else if sender.tag == 2 {
            controller.dialogueType = .seession_completed_alert
        } else {
            
        }
        presentAsSheet(controller)
    }

    @objc func okAction(_ sender: NSButton) {
        dismiss(nil)
    }
}
