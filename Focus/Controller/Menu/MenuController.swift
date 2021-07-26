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

class MenuController: BaseViewController {
    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var btnInfo: NSButton!

    @IBOutlet var checkBoxDND: NSButton!
    @IBOutlet var lblDnDInfo: NSTextField!

    @IBOutlet var checkBoxFocusTime: NSButton!
    @IBOutlet var txtBreakTime: NSTextField! // hide

    @IBOutlet var popBreakTime: NSPopUpButton!
    @IBOutlet var lblBrekInfo: NSTextField!

    @IBOutlet var txtFocusTime: NSTextField! // hide
    @IBOutlet var popFocusTime: NSPopUpButton!

    @IBOutlet var lblFocusInfo: NSTextField!
    @IBOutlet var lblFocusTInfo: NSTextField!

    @IBOutlet var checkBoxBlock: NSButton!
    @IBOutlet var lblBlockList: NSTextField!
//    @IBOutlet var comboBlock: NSComboBox!
    @IBOutlet var popBlock: NSPopUpButton!

    @IBOutlet var lblFocusLength: NSTextField!
    @IBOutlet var btn30m: CustomButton!
    @IBOutlet var btn1Hr: CustomButton!
    @IBOutlet var btn2Hr: CustomButton!
    @IBOutlet var btnUntillI: CustomButton!

    @IBOutlet var btnStop: CustomButton!
    @IBOutlet var btnCostomizeSetting: CustomButton!

    let viewModel: MenuViewModelType = MenuViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
    }

    @IBAction func showInfoAction(_ sender: Any) {
        lblDnDInfo.isHidden = !lblDnDInfo.isHidden
        lblFocusTInfo.isHidden = !lblFocusTInfo.isHidden
    }
}

extension MenuController: BasicSetupType {
    func setUpText() {
        btnCostomizeSetting.title = NSLocalizedString("Home.customize_setting", comment: "Customize Setting")

        checkBoxDND.title = Focus.Options.dnd.title
        lblDnDInfo.stringValue = Focus.Options.dnd.information
        checkBoxFocusTime.title = Focus.Options.focus_break.title
        lblBrekInfo.stringValue = Focus.Options.focus_break_1.title
        lblFocusInfo.stringValue = Focus.Options.focus_break_2.title
        lblFocusTInfo.stringValue = Focus.Options.focus_break.information

        checkBoxBlock.title = Focus.Options.block_program_website.title
        lblBlockList.stringValue = Focus.Options.block_list.title
        lblFocusLength.stringValue = Focus.Options.block_program_website.information

        btnStop.title = Focus.StopTime.stop_focus.title
        btn1Hr.title = Focus.StopTime.one_hr.title
        btn2Hr.title = Focus.StopTime.two_hr.title
        btn30m.title = Focus.StopTime.half_past.title
        btnUntillI.title = Focus.StopTime.untill_press_stop.title
    }

    func setUpViews() {
    }

    func bindData() {
        popBlock.menu = viewModel.input.getBlockList().0
        popFocusTime.menu = Focus.FocusTime.focustimes
        popBreakTime.menu = Focus.BreakTime.breaktimes

        btnCostomizeSetting.target = self
        btnCostomizeSetting.action = #selector(openCustomSetting)

        setupFocusStopAction(arrButtons: [btn30m, btn1Hr, btn2Hr, btnUntillI, btnStop])
        setupFocusOptionAction(arrButtons: [checkBoxDND, checkBoxFocusTime, checkBoxBlock])
    }

    //Focus set Action
    func setupFocusStopAction(arrButtons: [CustomButton]) {
        for (i, btn) in arrButtons.enumerated() {
            guard let option = Focus.StopTime(rawValue: i) else { return }
            btn.target = self
            btn.tag = option.rawValue
            btn.buttonColor = option.color
            btn.activeButtonColor = option.color
            btn.textColor = .white
            btn.action = #selector(buttonEventHandler(_:))
        }
    }

    //Checkbox Action
    func setupFocusOptionAction(arrButtons: [NSButton]) {
        for (i, btn) in arrButtons.enumerated() {
            guard let option = Focus.Options(rawValue: i) else { return }
            btn.target = self
            btn.tag = option.rawValue
            btn.state = option.isOn
            btn.action = #selector(checkBoxEventHandler(_:))
        }
    }

    @objc func closeWindow() {
        NSApp.terminate(self)
    }

    @objc func buttonEventHandler(_ sender: NSButton) {
        guard let focusTime = Focus.StopTime(rawValue: sender.tag) else { return }
        viewModel.input.updateFocusStop(time: focusTime) { isUpdate, _ in
            if isUpdate != nil {
                let controller = FocusDialogueViewC(nibName: "FocusDialogueViewC", bundle: nil)
                switch focusTime {
                case .half_past:
                    controller.dialogueType = .break_sequence_alert
                case .one_hr:
                    controller.dialogueType = .end_break_alert
                case .two_hr:
                    controller.dialogueType = .warning_forced_pause_alert
                case .untill_press_stop:
                    controller.dialogueType = .seession_completed_alert
                case .stop_focus:
                    controller.dialogueType = .till_stop_alert
                }
                self.presentAsModalWindow(controller)
            }
        }
    }

    @objc func checkBoxEventHandler(_ sender: NSButton) {
        guard let focusOption = Focus.Options(rawValue: sender.tag) else { return }
        viewModel.input.updateFocusOption(option: focusOption, state: sender.state) { _, _ in
        }
    }

    @IBAction func handleBlockSelection(_ sender: Any) {
        guard sender is NSPopUpButton else { return }
        if popBlock.selectedTag() == -1 {
            openCustomSetting()
        }
        print("Selected block:", popBlock.titleOfSelectedItem ?? "")

        // Here set the Block object in focus object
    }

    @IBAction func foucsTimeSelection(_ sender: Any) {
        guard let popup = sender as? NSPopUpButton else { return }
        print("Selected Focus Time:", popup.titleOfSelectedItem ?? "")
        viewModel.input.focusObj?.stop_focus_after_time = Double(popup.titleOfSelectedItem ?? "15") ?? Double(Focus.FocusTime.fifteen.value)
    }

    @IBAction func breakTimeSelection(_ sender: Any) {
        guard let popup = sender as? NSPopUpButton else { return }
        print("Selected Break Time:", popup.titleOfSelectedItem ?? "")

        viewModel.input.focusObj?.short_break_time = Double(popup.titleOfSelectedItem ?? "5") ?? Double(Focus.BreakTime.five.value)
    }

    @objc func openCustomSetting() {
//        performSegue(withIdentifier: "segueSetting", sender: self)
        if let vc = WindowsManager.getVC(withIdentifier: "sidCustomSetting", ofType: CustomSettingController.self, storyboard: "CustomSetting") {
            present(vc, animator: ViewShowAnimator())
        }
    }
}

extension MenuController {
    func setupData() {
        guard let obj = viewModel.input.focusObj else { return }
        popBreakTime.title = String(format: "%@", obj.short_break_time)
        popFocusTime.title = String(format: "%@", obj.stop_focus_after_time)

        for btn in [btn30m, btn1Hr, btn2Hr, btnUntillI, btnStop] {
            btn?.isEnabled = !obj.is_focusing
        }
    }
}
