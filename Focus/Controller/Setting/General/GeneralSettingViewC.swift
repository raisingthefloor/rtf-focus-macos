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

class GeneralSettingViewC: BaseViewController {
    @IBOutlet var lblTitle: NSTextField!

    @IBOutlet var lblBehaviorTitle: NSTextField!
    @IBOutlet var checkBoxWarning: NSButton!
    @IBOutlet var lbllockInfo: NSTextField!

    @IBOutlet var checkBoxShowTimer: NSButton!
    @IBOutlet var checkBoxEachBreak: NSButton!

    @IBOutlet var checkBoxFocusTime: NSButton!
    @IBOutlet var popBreakTime: NSPopUpButton!
    @IBOutlet var lblBrekInfo: NSTextField!
    @IBOutlet var popFocusTime: NSPopUpButton!
    @IBOutlet var lblFocusInfo: NSTextField!

    @IBOutlet var lblUnblockingTitle: NSTextField!
    @IBOutlet var lblUnblockingInfo: NSTextField!

    @IBOutlet var listContainerV: NSView!
    @IBOutlet var tblView: NSTableView!

    @IBOutlet var lblOverrideInfo: NSTextField!

    @IBOutlet var btnContainerV: NSView!
    @IBOutlet var lblListInfo: NSTextField!
    @IBOutlet var btnAddApp: CustomButton!
    @IBOutlet var btnAddWeb: CustomButton!

    let viewModel: GeneralSettingModelType = GeneralSettingModel()

    override func setTitle() -> String { return SettingOptions.general_setting.title }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
        tableViewSetup()
    }
}

extension GeneralSettingViewC: BasicSetupType {
    func setUpText() {
        lblBehaviorTitle.stringValue = NSLocalizedString("GS.behaviorTitle", comment: "Behavior during focus sessions:")
        checkBoxWarning.title = NSLocalizedString("GS.before_warning", comment: "Don't give me a 5 minute warning before scheduled focus sessions start")
//        lbllockInfo.stringValue = NSLocalizedString("GS.lock_computer_info", comment: "(To force me to take a break away from computer for at LEAST 1 min.)")

        checkBoxFocusTime.title = NSLocalizedString("GS.provide_focus_time", comment: "Provide short")
        lblBrekInfo.stringValue = NSLocalizedString("GS.break_for", comment: "breaks for every")
        lblFocusInfo.stringValue = NSLocalizedString("GS.schedule_session", comment: "of scheduled Focus sessions")

        checkBoxShowTimer.title = NSLocalizedString("GS.countdown_timer", comment: "Show count down timer in minutes for break start and end")
        checkBoxEachBreak.title = NSLocalizedString("GS.block_screen_each", comment: "Block screen for the first minute of each break to encourage me to stand up and stretch")

        lblUnblockingTitle.stringValue = NSLocalizedString("GS.unblockingtitle", comment: "Allow me to temporarily unblock these items during focus sessions:")
        lblUnblockingInfo.stringValue = NSLocalizedString("GS.unblockinginfo", comment: "If you need access to a program or website, but it is blocked during a focus session, then you can \nuse this feature to unblock it.")

//        lblAllowInfo.stringValue = NSLocalizedString("GS.allowinfo", comment: "This feature  allows user to override a block for the rest of the day.")
//        lblOverrideTitle.stringValue = NSLocalizedString("GS.overridetitle", comment: "List of allowable overrides.")
        lblOverrideInfo.stringValue = NSLocalizedString("GS.overrideinfo", comment: "Check an item below to unblock it until midnight (or until you uncheck it):")

        lblListInfo.stringValue = NSLocalizedString("GS.listInfo", comment: "This list cannot be changed while a focus session is in progress.")
        btnAddApp.title = NSLocalizedString("Button.add_app", comment: "Add App")
        btnAddWeb.title = NSLocalizedString("Button.add_website", comment: "Add Website")
    }

    func setUpViews() {
        setupData()

        view.background_color = .white
        btnAddApp.buttonColor = Color.green_color
        btnAddApp.activeButtonColor = Color.green_color
        btnAddApp.textColor = .white
        btnAddApp.font = NSFont.systemFont(ofSize: 12, weight: .semibold)

        btnAddWeb.buttonColor = Color.green_color
        btnAddWeb.activeButtonColor = Color.green_color
        btnAddWeb.textColor = .white
        btnAddWeb.font = NSFont.systemFont(ofSize: 12, weight: .semibold)

        listContainerV.border_color = Color.dark_grey_border
        listContainerV.border_width = 0.5
        listContainerV.background_color = .white
        listContainerV.corner_radius = 4

        btnContainerV.background_color = Color.list_bg_color

        lblTitle.font = NSFont.systemFont(ofSize: 18, weight: .semibold)
        lblTitle.textColor = .black

        lblBehaviorTitle.font = NSFont.systemFont(ofSize: 12, weight: .semibold)
        lblBehaviorTitle.textColor = .black

        checkBoxWarning.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        checkBoxWarning.tag = 0
        checkBoxFocusTime.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        checkBoxFocusTime.tag = 1

        lblBrekInfo.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        lblBrekInfo.textColor = .black
//        lblFocusInfo.font = NSFont.systemFont(ofSize: 12, weight: .semibold) // Italic
        lblFocusInfo.textColor = .black

        checkBoxShowTimer.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        checkBoxShowTimer.tag = 2
        checkBoxEachBreak.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        checkBoxEachBreak.tag = 3

        lblUnblockingTitle.font = NSFont.systemFont(ofSize: 12, weight: .semibold)
        lblUnblockingTitle.textColor = .black

//        lblUnblockingInfo.font = NSFont.systemFont(ofSize: 12, weight: .regular) // Italic
        lblUnblockingInfo.textColor = .black

        lblOverrideInfo.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        lblOverrideInfo.textColor = .black

//        lblListInfo.font = NSFont.systemFont(ofSize: 12, weight: .regular) // Italic
        lblListInfo.textColor = .black
    }

    func bindData() {
        btnAddWeb.target = self
        btnAddWeb.action = #selector(addWebAction(_:))

        btnAddApp.target = self
        btnAddApp.action = #selector(addAppAction(_:))

        guard let objF = DBManager.shared.getCurrentBlockList().objFocus else { return }
        btnAddWeb.isEnabled = !objF.is_focusing
        btnAddApp.isEnabled = !objF.is_focusing
    }

    func disableControl() -> Bool {
        guard let objF = DBManager.shared.getCurrentBlockList().objFocus else { return false }
        btnAddWeb.isEnabled = !objF.is_focusing
        btnAddApp.isEnabled = !objF.is_focusing

//        checkBoxWarning.isEnabled = !objF.is_focusing
//        checkBoxShowTimer.isEnabled = !objF.is_focusing
//        checkBoxEachBreak.isEnabled = !objF.is_focusing

        if objF.is_focusing {
            openErrorDialogue()
            setupData()
        }
        return true
    }

    func openErrorDialogue() {
        let errorDialog = ErrorDialogueViewC(nibName: "ErrorDialogueViewC", bundle: nil)
        errorDialog.errorType = .general_setting_error
        errorDialog.objBl = DBManager.shared.getCurrentBlockList().objBl
        presentAsSheet(errorDialog)
    }
}

extension GeneralSettingViewC {
    func setupData() {
        _ = viewModel.input.getGeneralCategoryData()
        checkBoxWarning.state = (viewModel.objGCategory?.general_setting?.warning_before_schedule_session_start == true) ? .on : .off
//        checkBoxFocusTime.state = (viewModel.objGCategory?.general_setting?.provide_short_break_schedule_session == true) ? .on : .off
        checkBoxShowTimer.state = (viewModel.objGCategory?.general_setting?.show_count_down_for_break_start_end == true) ? .on : .off
        checkBoxEachBreak.state = (viewModel.objGCategory?.general_setting?.block_screen_first_min_each_break == true) ? .on : .off
//        popBreakTime.title = String(format: "%d", viewModel.objGCategory?.general_setting?.break_time as! CVarArg)
//        popFocusTime.title = String(format: "%d", viewModel.objGCategory?.general_setting?.for_every_time as! CVarArg)
    }

    @IBAction func checkBoxEventHandler(_ sender: NSButton) {
        print(" Check Box Event : \(sender.state) ::: \(sender.title)")
        if disableControl() {
            return
        }
        let isChecked = (sender.state == .on) ? true : false
        switch sender.tag {
        case 0:
            viewModel.objGCategory?.general_setting?.warning_before_schedule_session_start = isChecked
        case 1:
            viewModel.objGCategory?.general_setting?.provide_short_break_schedule_session = isChecked
        case 2:
            viewModel.objGCategory?.general_setting?.show_count_down_for_break_start_end = isChecked
        case 3:
            viewModel.objGCategory?.general_setting?.block_screen_first_min_each_break = isChecked
        default:
            break
        }
        DBManager.shared.saveContext()
    }

    @objc func addAppAction(_ sender: NSButton) {
        if disableControl() {
            return
        }

        let objCat = viewModel.input.getGeneralCategoryData().gCat
        if objCat != nil {
            let controller = BlocklistDialogueViewC(nibName: "BlocklistDialogueViewC", bundle: nil)
            controller.listType = .unblocking_list
            controller.addedSuccess = { [weak self] dataV in
                self?.viewModel.input.addAppWebData(data: dataV) { isStore in
                    if isStore {
                        self?.tblView.reloadData()
                    }
                }
            }
            presentAsSheet(controller)
        } else {
            // TODO: Need to check
        }
    }

    @objc func addWebAction(_ sender: NSButton) {
        if disableControl() {
            return
        }

        let objCat = viewModel.input.getGeneralCategoryData().gCat
        if objCat != nil {
            let inputDialogueCntrl = InputDialogueViewC(nibName: "InputDialogueViewC", bundle: nil)
            inputDialogueCntrl.inputType = .add_website
            inputDialogueCntrl.addedSuccess = { [weak self] dataV, _ in
                self?.viewModel.input.addAppWebData(data: dataV) { isStore in
                    if isStore {
                        self?.tblView.reloadData()
                    }
                }
            }
            presentAsSheet(inputDialogueCntrl)
        } else {
            // TODO: Need to check
        }
    }

    @objc func deleteSubCate(_ sender: NSButton) {
        if disableControl() {
            return
        }

        let arrSCat = viewModel.objGCategory?.sub_data?.allObjects as? [Block_SubCategory]
        guard let objBlock = arrSCat?[sender.tag] else { return }
        DBManager.shared.managedContext.delete(objBlock)
        DBManager.shared.saveContext()
        tblView.reloadData()
    }

    // Store the Categories as per selected blick list
    @objc func addSCategory(_ sender: NSButton) {
        let arrSCat = viewModel.objGCategory?.sub_data?.allObjects as? [Block_SubCategory]
        guard let objBlock = arrSCat?[sender.tag] else { return }
        objBlock.is_selected = !objBlock.is_selected
        DBManager.shared.saveContext()
    }
}

// MARK: - NSTableViewDataSource

extension GeneralSettingViewC: NSTableViewDataSource, NSTableViewDelegate {
    func tableViewSetup() {
        tblView.delegate = self
        tblView.dataSource = self
        tblView.usesAutomaticRowHeights = true
        tblView.reloadData()
        tblView.selectionHighlightStyle = .none
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return viewModel.input.getGeneralCategoryData().subCat.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let objSCat = viewModel.input.getGeneralCategoryData().subCat[row] as? Block_SubCategory
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "checkIdentifier") {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "checkId"), owner: self) as? ButtonCell {
                cell.configGCategoryCell(row: row, objSubCat: objSCat, target: self, action: #selector(addSCategory(_:)))
                return cell
            }

        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "nameIdentifier") {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nameId"), owner: self) as? ImageTextCell {
                cell.configCell(obj: objSCat)
                return cell
            }
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "deleteIdentifier") {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "deleteID"), owner: self) as? ButtonCell {
                cell.btnAddApp.tag = row
                cell.btnAddApp.target = self
                cell.btnAddApp.action = #selector(deleteSubCate(_:))
                return cell
            }
        }
        return nil
    }
}
