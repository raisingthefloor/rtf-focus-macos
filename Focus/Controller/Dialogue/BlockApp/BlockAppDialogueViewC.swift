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
    var viewModel: FocusDialogueViewModelType = FocusDialogueViewModel()

    var updateView: ((ButtonAction) -> Void)?

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
        guard let objBl = viewModel.currentSession?.arrObjBl.last as? Block_List else { return }
        let appName = ((dialogueType == .notifiction_block_alert) ? "Notifiction" : viewModel.application?.localizedName) ?? "-"
        var list_name = objBl.name ?? "-"
        if objBl.restart_computer || objBl.random_character {
            list_name = "🔒" + " " + list_name
        }

        let titleV = String(format: dialogueType.title, appName as! CVarArg)
        lblTitle.stringValue = titleV

        let titleDesc = String(format: dialogueType.description, appName as! CVarArg, list_name as! CVarArg)
        let attributedDesc = NSMutableAttributedString.getAttributedString(fromString: titleDesc)
        attributedDesc.apply(font: NSFont.systemFont(ofSize: 12, weight: .regular), subString: titleDesc)
        attributedDesc.alignment(alignment: .center, subString: titleDesc)
        attributedDesc.apply(font: NSFont.systemFont(ofSize: 12, weight: .semibold), subString: appName)
        attributedDesc.apply(font: NSFont.systemFont(ofSize: 12, weight: .semibold), subString: list_name)

        lblDesc.attributedStringValue = attributedDesc
        lblDesc.alignment = .center

        lblSubDesc.stringValue = dialogueType.sub_description
        lblSubDesc.isHidden = dialogueType.sub_description.isEmpty

        let buttonsV = dialogueType.option_buttons
        btnOk.title = buttonsV.last ?? ""
        btnStop.title = buttonsV.first ?? ""

        let subTitle = NSLocalizedString("Alert.block_app.show_blocklist", comment: "Show me the blocklist that is blocking this ...")
        let attributedText = NSMutableAttributedString.getAttributedString(fromString: subTitle)
        attributedText.apply(font: NSFont.systemFont(ofSize: 10, weight: .regular), subString: subTitle)
        attributedText.underLine(subString: subTitle)
        attributedText.alignment(alignment: .center, subString: subTitle)
        lblBottomInfo.attributedStringValue = attributedText
        lblBottomInfo.textColor = Color.blue_color

        let bottomInfo = NSLocalizedString("Alert.block_app.temp_access", comment: "Tell me how to allow temporary access to apps or websites...")
        let attributedStr = NSMutableAttributedString.getAttributedString(fromString: bottomInfo)
        attributedStr.underLine(subString: bottomInfo)
        attributedStr.apply(font: NSFont.systemFont(ofSize: 10, weight: .regular), subString: bottomInfo)
        attributedStr.alignment(alignment: .center, subString: bottomInfo)
        lblBottomInfo1.attributedStringValue = attributedStr

        lblBottomInfo1.isHidden = (dialogueType == .notifiction_block_alert) ? true : false
        lblBottomInfo1.textColor = Color.blue_color
    }

    func setUpViews() {
        view.window?.level = .floating
    }

    func themeSetUp() {
        lblTitle.font = NSFont.systemFont(ofSize: 18, weight: .black)
        lblSubDesc.font = NSFont.systemFont(ofSize: 12, weight: .regular)

        let bg_color = dialogueType.option_buttons_theme.bg_color
        let b_color = dialogueType.option_buttons_theme.border_color
        let bwidth = dialogueType.option_buttons_theme.border_width
        let font_color = dialogueType.option_buttons_theme.font_color

        btnStop.buttonColor = bg_color.last ?? Color.green_color
        btnStop.activeButtonColor = bg_color.last ?? Color.green_color
        btnStop.textColor = font_color.last ?? .white
        btnStop.borderColor = b_color.last ?? Color.green_color
        btnStop.borderWidth = bwidth
        btnOk.font = NSFont.systemFont(ofSize: 13, weight: .bold)

        btnOk.buttonColor = bg_color.first ?? Color.light_green_color
        btnOk.activeButtonColor = bg_color.first ?? Color.light_green_color
        btnOk.textColor = font_color.first ?? .white
        btnOk.borderColor = b_color.first ?? Color.green_color
        btnOk.borderWidth = bwidth
        btnOk.font = NSFont.systemFont(ofSize: 13, weight: .bold)

        view.border_color = Color.green_color
        view.border_width = 1
        view.background_color = Color.dialogue_bg_color
        view.corner_radius = 10
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
        updateView?(.normal_ok)
        dismiss(nil)
    }

    @objc func stopAction(_ sender: NSButton) {
        guard let objBl = viewModel.currentSession?.arrObjBl.last as? Block_List else {
            updateView?(.stop_session)
            dismiss(nil)
            return
        }

        if objBl.stop_focus_session_anytime {
            updateView?(.stop_session)
            dismiss(nil)
            return
        }
        let controller = DisincentiveViewC(nibName: "DisincentiveViewC", bundle: nil)
        controller.dialogueType = objBl.random_character ? .disincentive_xx_character_alert : .disincentive_signout_signin_alert
        controller.updateFocusStop = { focusStop in
            if focusStop == .stop_session {
                self.updateView?(focusStop)
                self.dismiss(nil)
            }
        }
        presentAsSheet(controller)
    }

    @objc func openBlockList() {
        if let vc = WindowsManager.getVC(withIdentifier: "sidCustomSetting", ofType: CustomSettingController.self, storyboard: "CustomSetting") {
            vc.selectOption = SettingOptions.block_setting
            presentAsModalWindow(vc)
        }
    }

    @objc func tempAccess() {
        if let vc = WindowsManager.getVC(withIdentifier: "sidCustomSetting", ofType: CustomSettingController.self, storyboard: "CustomSetting") {
            vc.selectOption = SettingOptions.general_setting
            presentAsModalWindow(vc)
        }
    }
}
