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
    let dataModel: DataModelType = DataModel()

    var focusStart: ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        dataModel.input.storeCategory() // Store first time only
        setUpText()
        setUpViews()
        bindData()
        preDataSetup()
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

        let button = view.window?.standardWindowButton(.zoomButton)
        button?.isEnabled = false

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
        popBlock.menu = dataModel.input.getBlockList(cntrl: .main_menu).0
        popBlock.selectItem(at: 0)

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
        let arrBlock = dataModel.input.getBlockList(cntrl: .main_menu).1
        let index = popBlock.selectedTag()
        if index == -1 {
            performSegue(withIdentifier: "segueSetting", sender: SettingOptions.block_setting)
        } else if index == -2 {
            viewModel.input.focusObj?.block_list_id = UUID() // fakeID
        } else {
            if !arrBlock.isEmpty {
                let objBlockList = arrBlock[index]
//                viewModel.input.focusObj.block_data = objBlockList
                viewModel.input.focusObj?.block_list_id = objBlockList.id
            }
        }
        DBManager.shared.saveContext()
    //    print("Selected block:", popBlock.titleOfSelectedItem ?? "")
    }

    @IBAction func foucsTimeSelection(_ sender: Any) {
        guard let popup = sender as? NSPopUpButton else { return }
        let index = popup.selectedTag()
        viewModel.input.focusObj?.stop_focus_after_time = Focus.FocusTime(rawValue: index)!.valueInSeconds
        DBManager.shared.saveContext()
    }

    @IBAction func breakTimeSelection(_ sender: Any) {
        guard let popup = sender as? NSPopUpButton else { return }
        let index = popup.selectedTag()
        viewModel.input.focusObj?.short_break_time = Focus.BreakTime(rawValue: index)!.valueInSeconds
        viewModel.input.focusObj?.break_lenght_time = Focus.BreakTime(rawValue: index)!.valueInSeconds
        viewModel.input.focusObj?.remaining_break_time = Focus.BreakTime(rawValue: index)!.valueInSeconds
        DBManager.shared.saveContext()
    }

    @objc func openCustomSetting() {
//        if let vc = WindowsManager.getVC(withIdentifier: "sidCustomSetting", ofType: CustomSettingController.self, storyboard: "CustomSetting") {
//            presentAsSheet(vc)
//        }
        performSegue(withIdentifier: "segueSetting", sender: self)
    }
}

extension MenuController {
    func preDataSetup() {
        guard let obj = viewModel.input.focusObj else { return }
        obj.short_break_time = Focus.BreakTime.three.valueInSeconds
        obj.break_lenght_time = Focus.BreakTime.three.valueInSeconds
        obj.remaining_break_time = Focus.BreakTime.three.valueInSeconds
        obj.stop_focus_after_time = Focus.FocusTime.fifteen.valueInSeconds
        blockStackV.isHidden = !obj.is_block_programe_select
        let arrBlock = dataModel.input.getBlockList(cntrl: .main_menu).1
        if !arrBlock.isEmpty {
            obj.block_list_id = arrBlock[0].id
        }
        DBManager.shared.saveContext()
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueSetting" {
            if let detailVC = segue.destinationController as? CustomSettingController {
                detailVC.selectOption = sender as? SettingOptions ?? SettingOptions.general_setting
                detailVC.updateView = { [weak self] _ in
                    self?.popBlock.menu = self?.dataModel.input.getBlockList(cntrl: .main_menu).0

                    if let arrBlock = self?.dataModel.input.getBlockList(cntrl: .main_menu).1,!arrBlock.isEmpty {
                        guard let obj = self?.viewModel.input.focusObj else { return }
                        obj.block_list_id = arrBlock[0].id
                        DBManager.shared.saveContext()
                    }
                }
            }
        }
    }
}
