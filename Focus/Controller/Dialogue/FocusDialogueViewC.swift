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
        if dialogueType == .long_break_alert {
            let timeC = Int(viewModel.currentSession?.objFocus?.used_focus_time ?? 100).secondsToTime()
            var time = ""
            if timeC.timeInHours != 0 {
                time = "\(timeC.timeInHours) Hours \(timeC.timeInMinutes) minutes"
            } else {
                time = "\(timeC.timeInMinutes) minutes"
            }
            lblTitle.stringValue = String(format: dialogueType.title, time)
        } else {
            lblTitle.stringValue = dialogueType.title
        }

        lblDesc.stringValue = dialogueType.description
        lblSubDesc.stringValue = dialogueType.sub_description

        lblSubTitle.stringValue = dialogueType.extented_title
        let buttonsValue = dialogueType.option_buttons

        btnStop.title = buttonsValue.first ?? "-"
        if dialogueType == .long_break_alert {
            let timeC = Int(viewModel.currentSession?.objFocus?.short_break_time ?? 100).secondsToTime()
            var time = ""
            if timeC.timeInHours != 0 {
                time = "\(timeC.timeInHours) hrs \(timeC.timeInMinutes) minute"
            } else {
                time = "\(timeC.timeInMinutes) minute"
            }
            btnContinue.title = String(format: buttonsValue.last ?? "", time)
        } else {
            btnContinue.title = buttonsValue.last ?? ""
        }

        btnTop.title = buttonsValue.last ?? ""
        btnTop.isHidden = (dialogueType != .long_break_alert) ? false : true
        btnContinue.isHidden = (dialogueType == .long_break_alert) ? false : true
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
            btn.buttonColor = (dialogueType == .long_break_alert) ? dialogueType.green : dialogueType.light_green
            btn.activeButtonColor = (dialogueType == .long_break_alert) ? dialogueType.green : dialogueType.light_green
            btn.textColor = (dialogueType == .long_break_alert) ? .white : dialogueType.green
            btn.borderColor = (dialogueType == .long_break_alert) ? .white : dialogueType.green
            btn.font = NSFont.systemFont(ofSize: 13, weight: .bold)
            enableDisable(btn: btn)
            btn.borderWidth = 0.5
            i = i + 1
            btnStackV.addArrangedSubview(btn)
        }
    }

    func themeSetUp() {
        lblSubTitle.textColor = .black

        lblTitle.font = NSFont.systemFont(ofSize: 18, weight: .bold)

        btnTop.buttonColor = dialogueType.green
        btnTop.activeButtonColor = dialogueType.green
        btnTop.textColor = .white
        btnTop.font = NSFont.systemFont(ofSize: 13, weight: .bold)

        btnStop.buttonColor = dialogueType.stop_color
        btnStop.activeButtonColor = dialogueType.stop_color
        btnStop.textColor = Color.black_color
        btnStop.borderColor = Color.dark_grey_border
        btnStop.borderWidth = 0.6
        btnStop.font = NSFont.systemFont(ofSize: 13, weight: .bold)

        btnContinue.buttonColor = dialogueType.light_green
        btnContinue.activeButtonColor = dialogueType.light_green
        btnContinue.textColor = dialogueType.green
        btnContinue.borderColor = dialogueType.green
        btnContinue.borderWidth = 0.6
        btnContinue.font = NSFont.systemFont(ofSize: 13, weight: .bold)

        view.border_color = Color.green_color
        view.border_width = 1
        view.background_color = Color.dialogue_bg_color
        view.corner_radius = 10

        // containerView.bgColor = Color.light_blue_color
    }

    func bindData() {
        btnStop.target = self
        btnStop.action = #selector(stopAction(_:))

        btnTop.target = self
        btnTop.action = #selector(topAction(_:))

        btnContinue.target = self
        btnContinue.action = #selector(continueAction(_:))
    }

    func enableDisable(btn: CustomButton) {
        let obj = viewModel.reminderSchedule
        if dialogueType == .schedule_reminded_without_blocklist_alert {
            switch btn.tag {
            case 0:
                btn.isEnabled = !(obj?.extend_info?.is_extend_very_short ?? false)
            case 1:
                btn.isEnabled = !(obj?.extend_info?.is_extend_short ?? false)
            case 2:
                btn.isEnabled = !(obj?.extend_info?.is_extend_mid ?? false)
            case 3:
                btn.isEnabled = !(obj?.extend_info?.is_extend_long ?? false)
            default: break
            }
        }

        if !dialogueType.is_extented_buttons.isEmpty {
            btn.isEnabled = !dialogueType.is_extented_buttons[btn.tag]
        }
    }
}

extension FocusDialogueViewC {
    @objc func extendTimeAction(_ sender: NSButton) {
        let extendVal = dialogueType.value[sender.tag]
        breakAction?(dialogueType.action, extendVal, ButtonValueType(rawValue: sender.tag)!)
        dismiss(nil)
    }

    @objc func stopAction(_ sender: NSButton) {
        if dialogueType == .schedule_reminded_without_blocklist_alert || dialogueType == .schedule_reminded_with_blocklist_alert {
            breakAction?(.skip_session, 0, .none)
            dismiss(nil)
            return
        }

        guard let objBl = viewModel.currentSession?.objBl else {
            breakAction?(.stop_session, 0, .none)
            dismiss(nil)
            return
        }

        if objBl.stop_focus_session_anytime {
            breakAction?(.stop_session, 0, .none)
            dismiss(nil)
            return
        }

        // Need to check the Condition as if all false but that never happedn
        let controller = DisincentiveViewC(nibName: "DisincentiveViewC", bundle: nil)
        controller.dialogueType = objBl.random_character ? .disincentive_xx_character_alert : .disincentive_signout_signin_alert
        controller.updateFocusStop = { focusStop in
            if focusStop == .stop_session {
                self.breakAction?(focusStop, 0, .none)
                self.dismiss(nil)
            }
        }
        presentAsSheet(controller)
    }

    @objc func topAction(_ sender: NSButton) {
        breakAction?(.normal_ok, 0, .none)
        dismiss(nil)
    }

    @objc func continueAction(_ sender: NSButton) {
        breakAction?(.normal_ok, 0, .none)
        dismiss(nil)
    }
}
