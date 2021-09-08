//
//  BlockAppDialogueViewC.swift
//  Focus
//
//  Created by Bhavi on 08/09/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Cocoa

class BlockAppDialogueViewC: NSViewController {
    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var lblDesc: NSTextField!
    @IBOutlet var lblSubDesc: NSTextField!

    @IBOutlet var btnOk: CustomButton!
    @IBOutlet var seperateV: NSBox!
    @IBOutlet var btnStop: CustomButton!

    @IBOutlet var lblBottomInfo: NSTextField!
    @IBOutlet var lblBottomInfo1: NSTextField!

    var dialogueType: FocusDialogue = .launch_block_app_alert

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        themeSetUp()
        bindData()
    }
}

extension BlockAppDialogueViewC: BasicSetupType {
    func setUpText() {
        let appName = (dialogueType == .notifiction_block_alert) ? "Notifiction" : "AppleTV"
        let titleV = String(format: dialogueType.title, appName)
        lblTitle.stringValue = titleV

        let titleDesc = String(format: dialogueType.description, appName, "Social Blocklist")
        let attributedDesc = NSMutableAttributedString.getAttributedString(fromString: titleDesc)
        attributedDesc.apply(font: NSFont.systemFont(ofSize: 13, weight: .regular), subString: titleDesc)
        attributedDesc.alignment(alignment: .center, subString: titleDesc)
        attributedDesc.apply(font: NSFont.systemFont(ofSize: 13, weight: .semibold), subString: appName)
        attributedDesc.apply(font: NSFont.systemFont(ofSize: 13, weight: .semibold), subString: "Social Blocklist")

        lblDesc.attributedStringValue = attributedDesc
        lblDesc.alignment = .center
        
        lblSubDesc.stringValue = dialogueType.sub_description
        lblSubDesc.isHidden = dialogueType.sub_description.isEmpty

        let buttonsV = dialogueType.option_buttons.titles
        btnOk.title = buttonsV.last ?? ""
        btnStop.title = buttonsV.first ?? ""

        let subTitle = NSLocalizedString("Alert.block_app.show_blocklist", comment: "Show me the blocklist that is blocking  this ...")
        let attributedText = NSMutableAttributedString.getAttributedString(fromString: subTitle)
        attributedText.underLine(subString: subTitle)
        lblBottomInfo.attributedStringValue = attributedText

        let bottomInfo = NSLocalizedString("Alert.block_app.temp_access", comment: "Tell me how to allow temporary access to apps or websites...")
        let attributedStr = NSMutableAttributedString.getAttributedString(fromString: bottomInfo)
        attributedStr.underLine(subString: bottomInfo)
        lblBottomInfo1.attributedStringValue = attributedStr
        lblBottomInfo1.isHidden = (dialogueType == .notifiction_block_alert) ? true : false
    }

    func setUpViews() {
        view.window?.level = .floating
    }

    func themeSetUp() {
        lblTitle.font = NSFont.systemFont(ofSize: 20, weight: .medium)

        let bg_color = dialogueType.option_buttons_theme.bg_color
        let b_color = dialogueType.option_buttons_theme.border_color
        let bwidth = dialogueType.option_buttons_theme.border_width
        let font_color = dialogueType.option_buttons_theme.font_color

        btnStop.buttonColor = bg_color.last ?? Color.green_color
        btnStop.activeButtonColor = bg_color.last ?? Color.green_color
        btnStop.textColor = font_color.last ?? .white
        btnStop.borderColor = b_color.last ?? Color.green_color
        btnStop.borderWidth = bwidth

        btnOk.buttonColor = bg_color.first ?? Color.light_green_color
        btnOk.activeButtonColor = bg_color.first ?? Color.light_green_color
        btnOk.textColor = font_color.first ?? .white
        btnOk.borderColor = b_color.first ?? Color.green_color
        btnOk.borderWidth = bwidth
    }

    func bindData() {
        btnOk.target = self
        btnOk.action = #selector(okAction(_:))

        btnStop.target = self
        btnStop.action = #selector(stopAction(_:))

        let blockList = NSClickGestureRecognizer(target: self, action: #selector(openBlockList))
        blockList.numberOfClicksRequired = 1
        lblBottomInfo.addGestureRecognizer(blockList)

        let tempAccess = NSClickGestureRecognizer(target: self, action: #selector(tempAccess))
        tempAccess.numberOfClicksRequired = 1
        lblBottomInfo1.addGestureRecognizer(tempAccess)
    }

    @objc func okAction(_ sender: NSButton) {
        dismiss(nil)
    }

    @objc func stopAction(_ sender: NSButton) {
        let controller = DisincentiveViewC(nibName: "DisincentiveViewC", bundle: nil)
        controller.dialogueType = .disincentive_xx_character_alert
        presentAsSheet(controller)
    }

    @objc func openBlockList() {
        // TODO: Open Block list View
        let controller = DisincentiveViewC(nibName: "DisincentiveViewC", bundle: nil)
        controller.dialogueType = .disincentive_signout_signin_alert
        presentAsSheet(controller)
    }

    @objc func tempAccess() {
        // TODO: Open Block list View
        let controller = BlockAppDialogueViewC(nibName: "BlockAppDialogueViewC", bundle: nil)
        controller.dialogueType = .notifiction_block_alert
        presentAsSheet(controller)
    }
}
