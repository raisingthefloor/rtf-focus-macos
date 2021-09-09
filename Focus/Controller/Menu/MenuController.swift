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

    @IBOutlet var blockStackV: NSStackView!
    @IBOutlet var checkBoxBlock: NSButton!
    @IBOutlet var lblBlockList: NSTextField!
//    @IBOutlet var comboBlock: NSComboBox!
    @IBOutlet var popBlock: NSPopUpButton!

    @IBOutlet var lblFocusLength: NSTextField!
    @IBOutlet var btn30m: CustomButton!
    @IBOutlet var btn1Hr: CustomButton!
    @IBOutlet var btn2Hr: CustomButton!
    @IBOutlet var btnUntillI: CustomButton!

    @IBOutlet var bottomView: NSView!
//    @IBOutlet var btnStop: CustomButton!
    @IBOutlet var lblCustomeInfo: NSTextField!
    @IBOutlet var btnCostomizeSetting: CustomButton!
    @IBOutlet var lblSetting: NSTextField!

    let viewModel: MenuViewModelType = MenuViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
       // setupData()
    }

    @IBAction func showInfoAction(_ sender: Any) {
        if btnInfo.state == .off {
            btnInfo.state = .off
            btnInfo.image = NSImage(named: "ic_info_filled")
        } else {
            btnInfo.image = NSImage(named: "ic_info")
            btnInfo.state = .on
        }

        let color: NSColor = (btnInfo.state == .on) ? Focus.Options.info_color : .clear
        lblDnDInfo.textColor = color
        lblFocusTInfo.textColor = color
        lblFocusLength.textColor = color
        lblCustomeInfo.textColor = color
    }
}

extension MenuController: BasicSetupType {
    func setUpText() {
        // btnCostomizeSetting.title = NSLocalizedString("Home.customize_setting", comment: "Customize Setting")
        lblSetting.stringValue = NSLocalizedString("Home.customize_setting", comment: "Customize Setting")
        lblTitle.stringValue = NSLocalizedString("Home.title", comment: "Start a Focus Session")
        title = NSLocalizedString("Home.title", comment: "Start a Focus Session")

        checkBoxDND.title = Focus.Options.dnd.title
        checkBoxDND.toolTip = Focus.Options.dnd.information

        lblDnDInfo.stringValue = Focus.Options.dnd.information
        checkBoxFocusTime.title = Focus.Options.focus_break.title
        checkBoxFocusTime.toolTip = Focus.Options.focus_break.information
        lblBrekInfo.stringValue = Focus.Options.focus_break_1.title
        lblFocusInfo.stringValue = Focus.Options.focus_break_2.title
        lblFocusTInfo.stringValue = Focus.Options.focus_break.information

        checkBoxBlock.title = Focus.Options.block_program_website.title
        lblBlockList.stringValue = Focus.Options.block_list.title
        lblFocusLength.stringValue = Focus.Options.block_program_website.information
        checkBoxBlock.toolTip = Focus.Options.block_program_website.information

        lblCustomeInfo.stringValue = Focus.Options.customize_setting.information
        bottomView.toolTip = Focus.Options.customize_setting.information

//        btnStop.title = Focus.StopTime.stop_focus.title
        btn1Hr.title = Focus.StopTime.one_hr.title
        btn2Hr.title = Focus.StopTime.two_hr.title
        btn30m.title = Focus.StopTime.half_past.title
        btnUntillI.title = Focus.StopTime.untill_press_stop.title

        btn1Hr.toolTip = Focus.Options.block_program_website.information
        btn2Hr.toolTip = Focus.Options.block_program_website.information
        btn30m.toolTip = Focus.Options.block_program_website.information
    }

    func setUpViews() {
        if let window: NSWindow = view.window {
            window.styleMask.remove(.fullScreen)
            window.styleMask.remove(.resizable)
            window.styleMask.remove(.miniaturizable)
            window.styleMask.remove(.fullSizeContentView)
        }
        themeSetUp()
    }

    func themeSetUp() {
        lblDnDInfo.textColor = Focus.Options.info_color
        lblFocusTInfo.textColor = Focus.Options.info_color
        lblFocusLength.textColor = Focus.Options.info_color
        lblCustomeInfo.textColor = Focus.Options.info_color
        lblSetting.textColor = .white
        lblSetting.font = NSFont.systemFont(ofSize: 15, weight: .medium)

        lblDnDInfo.font = NSFont.systemFont(ofSize: 12, weight: .regular)

        lblDnDInfo.textColor = .clear
        lblFocusTInfo.textColor = .clear
        lblFocusLength.textColor = .clear
        lblCustomeInfo.textColor = .clear

        bottomView.bgColor = Color.navy_blue_color
    }

    func bindData() {
        popBlock.menu = viewModel.input.getBlockList().0
        popFocusTime.menu = Focus.FocusTime.focustimes
        popBreakTime.menu = Focus.BreakTime.breaktimes

//        btnCostomizeSetting.target = self
//        btnCostomizeSetting.action = #selector(openCustomSetting)

        setupFocusStopAction(arrButtons: [btn30m, btn1Hr, btn2Hr, btnUntillI])
        setupFocusOptionAction(arrButtons: [checkBoxDND, checkBoxFocusTime, checkBoxBlock])

        let g = NSClickGestureRecognizer(target: self, action: #selector(openCustomSetting))
        g.numberOfClicksRequired = 1
        bottomView.addGestureRecognizer(g)
    }

    // Focus set Action
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

    // Checkbox Action
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
                    controller.dialogueType = .short_break_alert
                case .one_hr:
                    controller.dialogueType = .end_break_alert
                case .two_hr:
                    controller.dialogueType = .long_break_alert
                case .untill_press_stop:
                    controller.dialogueType = .seession_completed_alert
                case .stop_focus:
                    controller.dialogueType = .till_stop_alert
                }
                self.presentAsSheet(controller)
            }
        }
    }

    @objc func checkBoxEventHandler(_ sender: NSButton) {
        guard let focusOption = Focus.Options(rawValue: sender.tag) else { return }
        viewModel.input.updateFocusOption(option: focusOption, state: sender.state) { state, error in
            if error == nil {
                switch focusOption {
                case .block_program_website:
                    self.blockStackV.isHidden = ((state as? NSControl.StateValue) == .on) ? false : true
                case .dnd:
                    WindowsManager.runDNDScript()
                    if (state as? NSControl.StateValue) == .on {
                        WindowsManager.enableDND()
                    } else {
                        WindowsManager.disableDND()
                    }
                default:
                    break
                }
            }
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
//        if let vc = WindowsManager.getVC(withIdentifier: "sidCustomSetting", ofType: CustomSettingController.self, storyboard: "CustomSetting") {
//            presentAsSheet(vc)
//        }
        self.performSegue(withIdentifier: "segueMCustomSetting", sender: self)
    }
}

extension MenuController {
    func setupData() {
        guard let obj = viewModel.input.focusObj else { return }

        popBreakTime.title = String(format: "%d", obj.short_break_time)
        popFocusTime.title = String(format: "%d", obj.stop_focus_after_time)
        blockStackV.isHidden = !obj.is_block_programe_select

        for btn in [btn30m, btn1Hr, btn2Hr, btnUntillI] {
            btn?.isEnabled = !obj.is_focusing
        }
    }
}
