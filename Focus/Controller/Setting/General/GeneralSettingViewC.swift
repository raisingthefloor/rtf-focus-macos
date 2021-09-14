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

    let viewModel: BlockListViewModelType = BlockListViewModel()

    override func setTitle() -> String { return SettingOptions.general_setting.title }

    var blockList = ["email", "slack", "Skype", "LinkedIn", "Yahoo"]

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
        view.background_color = .white
        btnAddApp.buttonColor = Color.green_color
        btnAddApp.activeButtonColor = Color.green_color
        btnAddApp.textColor = .white
        btnAddApp.font = NSFont.systemFont(ofSize: 13, weight: .semibold)

        btnAddWeb.buttonColor = Color.green_color
        btnAddWeb.activeButtonColor = Color.green_color
        btnAddWeb.textColor = .white
        btnAddWeb.font = NSFont.systemFont(ofSize: 13, weight: .semibold)

        listContainerV.border_color = Color.dark_grey_border
        listContainerV.border_width = 0.5
        listContainerV.background_color = .white
        listContainerV.corner_radius = 4
        
        btnContainerV.background_color = Color.list_bg_color
        
        lblBehaviorTitle.font = NSFont.systemFont(ofSize: 12, weight: .semibold)
        lblBehaviorTitle.textColor = .black
        
        checkBoxWarning.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        checkBoxFocusTime.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        
        lblBrekInfo.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        lblBrekInfo.textColor = .black
        lblFocusInfo.font = NSFont.systemFont(ofSize: 12, weight: .semibold)
        lblFocusInfo.textColor = .black

        checkBoxShowTimer.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        checkBoxEachBreak.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        
        lblUnblockingTitle.font = NSFont.systemFont(ofSize: 12, weight: .semibold)
        lblUnblockingTitle.textColor = .black
        
        lblUnblockingInfo.font = NSFont.systemFont(ofSize: 12, weight: .regular) // Italic
        lblUnblockingInfo.textColor = .black
        
        lblOverrideInfo.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        lblOverrideInfo.textColor = .black

        lblListInfo.font = NSFont.systemFont(ofSize: 12, weight: .regular) // Italic
        lblListInfo.textColor = .black
    }

    func bindData() {
        btnAddWeb.target = self
        btnAddWeb.action = #selector(addWebAction(_:))

        btnAddApp.target = self
        btnAddApp.action = #selector(addAppAction(_:))

        popFocusTime.menu = Focus.FocusTime.focustimes
        popFocusTime.target = self
        popFocusTime.action = #selector(foucsTimeSelection(_:))

        popBreakTime.menu = Focus.BreakTime.breaktimes
        popBreakTime.target = self
        popBreakTime.action = #selector(breakTimeSelection(_:))
    }
}

extension GeneralSettingViewC {
    @IBAction func foucsTimeSelection(_ sender: Any) {
        guard let popup = sender as? NSPopUpButton else { return }
        print("Selected Focus Time:", popup.titleOfSelectedItem ?? "")
    }

    @IBAction func breakTimeSelection(_ sender: Any) {
        guard let popup = sender as? NSPopUpButton else { return }
        print("Selected Break Time:", popup.titleOfSelectedItem ?? "")
    }

    @objc func checkBoxEventHandler(_ sender: NSButton) {
        print(" Check Box Event : \(sender.state) ::: \(sender.title)")
    }

    @objc func addAppAction(_ sender: NSButton) {
    }

    @objc func addWebAction(_ sender: NSButton) {
        openPopup()
    }

    @objc func deleAppAction(_ sender: NSButton) {
        blockList.remove(at: sender.tag)
        tblView.reloadData()
    }

    func openPopup() {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print(paths[0])

        promptToForInput("Enter Web Url", "Copy Url from Webrowser and paste it below.", completion: { (value: String, action: Bool) in
            if action {
                print(value)

                let data: [String: Any] = ["url": value, "name": value, "created_at": Date(), "is_selected": false, "is_deleted": false, "block_type": BlockType.web.rawValue]
                viewModel.input.storeOverridesBlock(data: data) { _ in
                    self.blockList.append(value)
                    self.tblView.reloadData()
                }
            }
        })
    }
}

// MARK: - NSTableViewDataSource

extension GeneralSettingViewC: NSTableViewDataSource, NSTableViewDelegate {
    func tableViewSetup() {
        tblView.delegate = self
        tblView.dataSource = self
        tblView.usesAutomaticRowHeights = true
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return blockList.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "checkIdentifier") {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "checkId"), owner: nil) as? ButtonCell {
                return cell
            }

        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "nameIdentifier") {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nameId"), owner: nil) as? ImageTextCell {
                cell.configCell()
                return cell
            }
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "deleteIdentifier") {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "deleteID"), owner: nil) as? ButtonCell {
                cell.btnAddApp.tag = row
                cell.btnAddApp.target = self
                cell.btnAddApp.action = #selector(deleAppAction(_:))
                return cell
            }
        }
        return nil
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        if let tblV = notification.object as? NSTableView {
            let selectedRow = tblV.selectedRow
            let option = blockList[selectedRow]
        }
    }
}
