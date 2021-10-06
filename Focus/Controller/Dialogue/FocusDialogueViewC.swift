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
    @IBOutlet var btnTop: CustomButton!
    @IBOutlet var containerView: NSView!
    @IBOutlet var lblSubTitle: NSTextField!
    @IBOutlet var btnStackV: NSStackView!
    @IBOutlet var btnContinue: CustomButton!
    @IBOutlet var btnStop: CustomButton!

    var dialogueType: FocusDialogue = .short_break_alert
    var viewModel: FocusDialogueViewModelType = FocusDialogueViewModel()

    var breakAction: ((ButtonAction, Int, ButtonValueType) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        themeSetUp()
        bindData()
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

        btnStop.title = buttonsValue.first ?? "-"
        btnTop.title = buttonsValue.last ?? ""
        btnTop.isHidden = (dialogueType != .long_break_alert) ? false : true
        btnContinue.isHidden = (dialogueType == .long_break_alert) ? false : true
        btnContinue.title = buttonsValue.last ?? ""
    }

    func setUpViews() {
        view.window?.level = .floating

        lblTitle.isHidden = dialogueType.title.isEmpty
        lblDesc.isHidden = dialogueType.description.isEmpty
        lblSubDesc.isHidden = dialogueType.sub_description.isEmpty
        lblSubTitle.isHidden = dialogueType.extented_title.isEmpty
        containerView.isHidden = dialogueType.extented_buttons.isEmpty

        var i = 0
        for value in dialogueType.extented_buttons {
            let btn = CustomButton(title: value, target: self, action: #selector(extendTimeAction(_:)))
            btn.tag = i
            btn.buttonColor = dialogueType.light_green
            btn.activeButtonColor = dialogueType.light_green
            btn.textColor = dialogueType.green
            btn.borderColor = dialogueType.green
            if !dialogueType.is_extented_buttons.isEmpty {
                btn.isEnabled = !dialogueType.is_extented_buttons[i]
            }
            btn.borderWidth = 0.5
            i = i + 1
            btnStackV.addArrangedSubview(btn)
        }
    }

    func themeSetUp() {
        lblSubTitle.textColor = .black

        lblTitle.font = NSFont.systemFont(ofSize: 20, weight: .bold)

        btnTop.buttonColor = dialogueType.green
        btnTop.activeButtonColor = dialogueType.green
        btnTop.textColor = .white

        btnStop.buttonColor = dialogueType.light_green
        btnStop.activeButtonColor = dialogueType.light_green
        btnStop.textColor = Color.black_color
        btnStop.borderColor = Color.dark_grey_border
        btnStop.borderWidth = 0.6

        containerView.bgColor = Color.light_blue_color
    }

    func bindData() {
        btnStop.target = self
        btnStop.action = #selector(stopAction(_:))

        btnTop.target = self
        btnTop.action = #selector(topAction(_:))
    }
}

extension FocusDialogueViewC {
    @objc func extendTimeAction(_ sender: NSButton) {
        let extendVal = dialogueType.value[sender.tag]
        breakAction?(dialogueType.action, extendVal, ButtonValueType(rawValue: sender.tag)!)
        dismiss(nil)
    }

    @objc func stopAction(_ sender: NSButton) {
        if let anyTime = viewModel.currentSession?.objBl?.stop_focus_session_anytime, anyTime {
            breakAction?(.stop_session, 0, .none)
            dismiss(nil)
            return
        }
        // Need to check the Condition as if all false but that never happedn
        let controller = DisincentiveViewC(nibName: "DisincentiveViewC", bundle: nil)
        controller.dialogueType = (viewModel.currentSession?.objBl?.random_character ?? false) ? .disincentive_xx_character_alert : .disincentive_signout_signin_alert
        controller.updateFocusStop = { focusStop in
            self.breakAction?(focusStop, 0, .none)
            self.dismiss(nil)
        }
        presentAsSheet(controller)
    }

    @objc func topAction(_ sender: NSButton) {
        breakAction?(.normal_ok, 0, .none)
        dismiss(nil)
    }
}
