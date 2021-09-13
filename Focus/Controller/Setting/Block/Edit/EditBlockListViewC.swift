//
//  EditBlockListViewC.swift
//  Focus
//
//  Created by Bhavi on 10/09/21.
//  Copyright © 2021 Raising the Floor. All rights reserved.
//

import Cocoa

class EditBlockListViewC: BaseViewController {
    @IBOutlet var lblTitle: NSTextField!
    @IBOutlet var lblSubTitle: NSTextField!

    @IBOutlet var lblBlockTitle: NSTextField!
    @IBOutlet var mainView: NSView!

    @IBOutlet var comboBlock: NSPopUpButton!
    @IBOutlet var lblListTitle: NSTextField!

    @IBOutlet var lblCategoryTitle: NSTextField!
    @IBOutlet var tblCategory: NSTableView!

    @IBOutlet var lblBlockAppTitle: NSTextField!
    @IBOutlet var tblBlock: NSTableView!

    @IBOutlet var btnBAddApp: CustomButton!
    @IBOutlet var btnBAddWeb: CustomButton!

    @IBOutlet var lblExceptionTitle: NSTextField!
    @IBOutlet var lblExceptionSubTitle: NSTextField!
    @IBOutlet var tblNotBlock: NSTableView!
    @IBOutlet var btnNBAddApp: CustomButton!
    @IBOutlet var btnNBAddWeb: CustomButton!

    @IBOutlet var lblBlockBehaviour: NSTextField!
    @IBOutlet var radioShortLongBreak: NSButton!
    @IBOutlet var radioLongBreak: NSButton!
    @IBOutlet var radioAllBreak: NSButton!

    @IBOutlet var lblEarlyTitle: NSTextField!
    @IBOutlet var radioStopAnyTime: NSButton!
    @IBOutlet var radioStopFocus: NSButton!
    @IBOutlet var txtCharacter: NSTextField!
    @IBOutlet var lblRandom: NSTextField!

    @IBOutlet var radioRestart: NSButton!

    let viewModel: BlockListViewModelType = BlockListViewModel()
    var webSites: [Override_Block] = []

    var blockList = ["email", "slack", "Skype", "LinkedIn", "Yahoo"]

    let cellIdentifier: String = "checkboxCellID"
    let addCellIdentifier: String = "addCellID"

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpText()
        setUpViews()
        bindData()
        tableViewSetup()
    }
}

extension EditBlockListViewC: BasicSetupType {
    func setUpText() {
        lblTitle.stringValue = NSLocalizedString("BS.title", comment: "Edit Blocklists")
        lblSubTitle.stringValue = NSLocalizedString("BS.subTitle", comment: "A blocklist is a group of apps, websites and other items that you can choose to block during a focus session. Learn more about Blocklists")

        lblBlockTitle.stringValue = NSLocalizedString("BS.select_list", comment: "Select a blocklist to edit:")
        lblListTitle.stringValue = NSLocalizedString("BS.following_select_list", comment: "The following settings only apply to the selected blocklist")

        lblCategoryTitle.stringValue = NSLocalizedString("BS.category_title", comment: "Block all items in these categories:")
        lblBlockAppTitle.stringValue = NSLocalizedString("BS.block_app_title", comment: "Also, block these apps & websites:")

        btnBAddApp.title = NSLocalizedString("Button.add_app", comment: "Add App")
        btnBAddWeb.title = NSLocalizedString("Button.add_website", comment: "Add Website")

        btnNBAddApp.title = NSLocalizedString("Button.add_app", comment: "Add App")
        btnNBAddWeb.title = NSLocalizedString("Button.add_website", comment: "Add Website")

        lblExceptionTitle.stringValue = NSLocalizedString("BS.exception_title", comment: "Exceptions to blocked items:")
        lblExceptionSubTitle.stringValue = NSLocalizedString("BS.exception_subtitle", comment: "These will not be blocked even if in one of the lists above:")

        lblBlockBehaviour.stringValue = NSLocalizedString("BS.block_behaviour", comment: "Blocklist behavior during breaks:")
        radioShortLongBreak.title = NSLocalizedString("BS.short_long_break", comment: "Unblock this blocklist during short and long breaks")
        radioLongBreak.title = NSLocalizedString("BS.long_break", comment: "Unblock this blocklist during long breaks only")
        radioAllBreak.title = NSLocalizedString("BS.all_break", comment: "Keep this blocklist blocked during all breaks")

        lblEarlyTitle.stringValue = NSLocalizedString("BS.early_title", comment: "Discourage me from stopping early:")

        radioStopAnyTime.title = NSLocalizedString("BS.stop_any_time", comment: "No, let me stop the focus session at any time")
        radioStopFocus.title = NSLocalizedString("BS.stop_focus_session", comment: "Yes, make me type to stop the focus session:")
        lblRandom.stringValue = NSLocalizedString("BS.random_chracter", comment: "random characters")
        radioRestart.title = NSLocalizedString("BS.restart", comment: "Yes, make me restart my computer to stop the focus session")
    }

    func setUpViews() {
        mainView.border_color = Color.dark_grey_border
        mainView.border_width = 0.6
        mainView.background_color = Color.light_green_color
        mainView.corner_radius = 6

        btnBAddApp.buttonColor = Color.green_color
        btnBAddApp.activeButtonColor = Color.green_color
        btnBAddApp.textColor = .white
        btnBAddApp.font = NSFont.systemFont(ofSize: 13, weight: .semibold)

        btnBAddWeb.buttonColor = Color.green_color
        btnBAddWeb.activeButtonColor = Color.green_color
        btnBAddWeb.textColor = .white
        btnBAddWeb.font = NSFont.systemFont(ofSize: 13, weight: .semibold)

        btnNBAddApp.buttonColor = Color.green_color
        btnNBAddApp.activeButtonColor = Color.green_color
        btnNBAddApp.textColor = .white
        btnNBAddApp.font = NSFont.systemFont(ofSize: 13, weight: .semibold)

        btnNBAddWeb.buttonColor = Color.green_color
        btnNBAddWeb.activeButtonColor = Color.green_color
        btnNBAddWeb.textColor = .white
        btnNBAddWeb.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
    }

    func bindData() {
        btnBAddWeb.target = self
        btnBAddWeb.action = #selector(addWebAction(_:))

        btnBAddApp.target = self
        btnBAddApp.action = #selector(addAppAction(_:))

        btnNBAddWeb.target = self
        btnNBAddWeb.action = #selector(addWebAction(_:))

        btnNBAddApp.target = self
        btnNBAddApp.action = #selector(addAppAction(_:))
    }

    @objc func addAppAction(_ sender: NSButton) {
    }

    @objc func addWebAction(_ sender: NSButton) {
        openPopup()
    }

    @objc func deleAppAction(_ sender: NSButton) {
    }

    func openPopup() {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print(paths[0])

        promptToForInput("Enter Web Url", "Copy Url from Webrowser and paste it below.", completion: { (value: String, action: Bool) in
            if action {
                print(value)

                let data: [String: Any] = ["url": value, "name": value, "created_at": Date(), "is_selected": false, "is_deleted": false, "block_type": BlockType.web.rawValue]
                viewModel.input.storeOverridesBlock(data: data) { _ in
                }
            }
        })
    }
}

extension EditBlockListViewC: NSTableViewDataSource, NSTableViewDelegate {
    func tableViewSetup() {
        tblCategory.delegate = self
        tblCategory.dataSource = self
        tblCategory.usesAutomaticRowHeights = true

        tblBlock.delegate = self
        tblBlock.dataSource = self
        tblBlock.usesAutomaticRowHeights = true

        tblNotBlock.delegate = self
        tblNotBlock.dataSource = self
        tblNotBlock.usesAutomaticRowHeights = true
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return blockList.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return setupCellForDifferentTable(tableView, viewFor: tableColumn, row: row)
    }

    func setupCellForDifferentTable(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == tblCategory {
            
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "nameIdentifier") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nameId"), owner: nil) as? ButtonCell {
                    cell.btnAddApp.isEnabled = false
                    cell.btnAddApp.image = #imageLiteral(resourceName: "ic_info_filled")
                    cell.btnAddApp.title = blockList[row]
                    return cell
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "checkIdentifier") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "checkId"), owner: nil) as? ButtonCell {
                    cell.btnAddApp.tag = row
                    cell.btnAddApp.target = self
                    cell.btnAddApp.action = #selector(deleAppAction(_:))
                    return cell
                }
            }

        } else if tableView == tblBlock {
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "nameIdentifier") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nameId"), owner: nil) as? ButtonCell {
                    cell.btnAddApp.isEnabled = false
                    cell.btnAddApp.image = #imageLiteral(resourceName: "ic_info_filled")
                    cell.btnAddApp.title = blockList[row]
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

        } else {
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "nameIdentifier") {
                if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "nameId"), owner: nil) as? ButtonCell {
                    cell.btnAddApp.isEnabled = false
                    cell.btnAddApp.image = #imageLiteral(resourceName: "ic_info_filled")
                    cell.btnAddApp.title = blockList[row]
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
