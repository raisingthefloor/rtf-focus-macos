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

class MenuController: BaseViewController, NSWindowDelegate {
    @IBOutlet var containerView: NSView!
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

    var viewModel: MenuViewModelType = MenuViewModel()

    var focusStart: ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
//        preDataSetup()
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

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if viewModel.viewCntrl != .main_menu {
            focusStart?(false)
        }
        return true
    }
}

extension MenuController: BasicSetupType {
    func setUpText() {
        // btnCostomizeSetting.title = NSLocalizedString("Home.customize_setting", comment: "Customize Setting")
        let customize_setting = NSLocalizedString("Home.customize_setting", comment: "Customize Focus")
        let customize_setting_str = NSMutableAttributedString.getAttributedString(fromString: customize_setting)
        customize_setting_str.underLine(subString: customize_setting, lineColor: .white)
        customize_setting_str.apply(color: .white, subString: customize_setting)
        lblSetting.attributedStringValue = customize_setting_str

        lblSetting.textColor = .white
        lblTitle.stringValue = NSLocalizedString("Home.title", comment: "Start a Focus Session")
        title = "" // NSLocalizedString("Home.title", comment: "Start a Focus Session")

        checkBoxDND.title = Focus.Options.dnd.title
        checkBoxDND.toolTip = Focus.Options.dnd.information

        lblDnDInfo.stringValue = Focus.Options.dnd.information
        checkBoxFocusTime.title = Focus.Options.focus_break.title
        checkBoxFocusTime.toolTip = Focus.Options.focus_break.information
        lblBrekInfo.stringValue = Focus.Options.focus_break_length.title
        lblFocusInfo.stringValue = Focus.Options.focus_stop_length.title
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
        view.window?.delegate = self
        themeSetUp()
    }

    func themeSetUp() {
        containerView.background_color = Color.main_bg_color

        lblDnDInfo.textColor = Focus.Options.info_color
        lblFocusTInfo.textColor = Focus.Options.info_color
        lblFocusLength.textColor = Focus.Options.info_color
        lblCustomeInfo.textColor = Focus.Options.info_color
        lblSetting.textColor = .white

        lblSetting.font = NSFont.systemFont(ofSize: 14, weight: .medium)

//        lblDnDInfo.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        btn1Hr.font = NSFont.systemFont(ofSize: 12, weight: .bold)
        btn2Hr.font = NSFont.systemFont(ofSize: 12, weight: .bold)
        btn30m.font = NSFont.systemFont(ofSize: 12, weight: .bold)
        btnUntillI.font = NSFont.systemFont(ofSize: 12, weight: .bold)

        lblDnDInfo.textColor = .clear
        lblFocusTInfo.textColor = .clear
        lblFocusLength.textColor = .clear
        lblCustomeInfo.textColor = .clear

        bottomView.bgColor = Color.navy_blue_color
    }

    func bindData() {
        popBlock.menu = viewModel.model.input.getBlockList(cntrl: .main_menu).nsMenu
        popBlock.selectItem(at: 0)
        popBlock.alignment = .left

        popFocusTime.menu = Focus.FocusTime.focustimes
        popBreakTime.menu = Focus.BreakTime.breaktimes

        popFocusTime.selectItem(at: 0)
        popBreakTime.selectItem(at: 1)

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
                self.focusStart?(true)
                self.dismiss(nil)
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
                default:
                    break
                }
            }
        }
    }

    // Block list selection
    @IBAction func handleBlockSelection(_ sender: Any) {
        guard sender is NSPopUpButton else { return }
        let arrBlock = viewModel.model.input.getBlockList(cntrl: .main_menu).blists
        let index = popBlock.selectedTag()
        if index == -1 {
            performSegue(withIdentifier: "segueSetting", sender: SettingOptions.block_setting)
        } else {
            if !arrBlock.isEmpty {
                let objBlockList = arrBlock[index]
                viewModel.focusDict["block_list_id"] = objBlockList.id
                viewModel.focusDict["is_block_list_dnd"] = objBlockList.is_dnd_category_on // This one used for cause If any blocklist has selected notification Category then it set here
            }
        }
    }

    @IBAction func foucsTimeSelection(_ sender: Any) {
        guard let popup = sender as? NSPopUpButton else { return }
        let index = popup.selectedTag()
        viewModel.focusDict[Focus.Options.focus_stop_length.key_name] = Focus.FocusTime(rawValue: index)!.valueInSeconds
    }

    @IBAction func breakTimeSelection(_ sender: Any) {
        guard let popup = sender as? NSPopUpButton else { return }
        let index = popup.selectedTag()
        viewModel.focusDict[Focus.Options.focus_break_length.key_name] = Focus.BreakTime(rawValue: index)!.valueInSeconds
    }

    @objc func openCustomSetting() {
        performSegue(withIdentifier: "segueSetting", sender: self)
    }
}

extension MenuController {
//    func preDataSetup() {
//        guard let obj = viewModel.input.focusObj else { return }
//        obj.original_break_lenght_time = Focus.BreakTime.three.valueInSeconds
//        obj.remaining_break_time = Focus.BreakTime.three.valueInSeconds
//        obj.stop_focus_after_time = Focus.FocusTime.fifteen.valueInSeconds
//        obj.original_stop_focus_after_time = Focus.FocusTime.fifteen.valueInSeconds
//        blockStackV.isHidden = !obj.is_block_programe_select
//        let arrBlock = viewModel.model.input.getBlockList(cntrl: .main_menu).blists
//        if !arrBlock.isEmpty {
//            if obj.is_block_programe_select {
//                obj.block_list_id = arrBlock[0].id
//            }
//        }
//        DBManager.shared.saveContext()
//    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueSetting" {
            if let detailVC = segue.destinationController as? CustomSettingController {
                detailVC.selectOption = sender as? SettingOptions ?? SettingOptions.general_setting
                detailVC.updateView = { [weak self] _ in
                    self?.popBlock.menu = self?.viewModel.model.input.getBlockList(cntrl: .main_menu).nsMenu
                    if let arrBlock = self?.viewModel.model.input.getBlockList(cntrl: .main_menu).blists,!arrBlock.isEmpty {
                        self?.viewModel.focusDict["block_list_id"] = !arrBlock.isEmpty ? arrBlock[0].id : nil
                        self?.viewModel.focusDict["is_block_list_dnd"] = !arrBlock.isEmpty ? arrBlock[0].is_dnd_category_on : false // This one used for cause If any blocklist has selected notification Category then it set here
                    }
                }
            }
        }
    }
}
